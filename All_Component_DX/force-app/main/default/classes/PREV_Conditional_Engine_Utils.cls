/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * A utililty class to handle operations related to condition based Preventive Maintenance activities.  
 *
 *
 * @author Sachin S
 * @version 
 * @since 2017
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                20 Feb 2017     Created.
 *  BAC-2273    Sachin S                30 Jun 2017     Enhancement to support '=','<' & '>' operators 
 *  BAC-2828    Sachin S                26 Jun 2017     Defect fix
 *****************************************************************************************************/

public class PREV_Conditional_Engine_Utils {

    Static final String STATUS_WO_DONE = 'Work Order Done'; 
    Static final String STATUS_WO_CREATED = 'Work Order Created';
    Static final String STATUS_WO_CANCELLED = 'Skipped';
    Static final String STATUS_WO_EXCEEDED = 'Exceeded Stop At';
    Static final String STATUS_WO_FAILED = 'Failed';
    Static final String ATTRIBUTE_TYPE_TECHNICAL = 'Technical';
    Static final String ATTRIBUTE_TYPE_SCHEMA = 'Schema';
    Static final String ATTRIBUTE_TYPE_STRING_LITERAL = 'Literal';
    Static final String CONDITION_TYPE_COMPARISON = 'Criteria_Comparison';
    Static Map<String, Id> recordTypeIDMap = new Map<String, Id>();
    Map<Id,ScheduleLogger> scheduleLogMap = new Map<Id, ScheduleLogger>();

    Set<String> technicalAttributes = new Set<String>();
    Set<String> schemaAttributes = new Set<String>();   
    Map<String,String> currentAttributeReadings = new Map<String,String>();
    Map<String,String> targetAttributeReadings = new Map<String,String>();  

    Map<String,String> prevEngineSettings;



    
    /*
        1. Parse Expression
        2. Get Related Ibs
        3. Get related latest counter reading for those IBs and for the given technical attribute
        4. Evaluate Expression
        5. Based on expression output, create Work Orders
        6. For Adjustment, check Previous work order status
    */

    public List<ScheduleLogger> scheduleOutputProcessor(Map<Id,SVMXC__ServiceMax_Processes__c> qualifiedPlanIdProcessMap ){

        System.debug(LoggingLevel.DEBUG, 'No. of Qualified PM Plans ' + qualifiedPlanIdProcessMap.size());

        List<SVMXC__PM_Schedule__c> scheduleOutputList = [SELECT Id, Name, SVMXC__SM_Expression_Internal_Value__c, SVMXC__SM_Expression_Display_Value__c, SVMXC__SM_Advanced_Expression__c, SVMXC__PM_Plan__c, SVMXC__PM_Plan__r.OwnerId, SVMXC__PM_Plan__r.Owner.isActive, SVMXC__PM_Plan__r.Name, SVMXC__PM_Plan__r.SVMXC__SM_Advanced_Expression__c, SVMXC__PM_Plan__r.SVMXC__Task_Template__c, SVMXC__SM_PM_Coverage__c, SVMXC__SM_Sequence__c,
                                                            SVMXC__PM_Plan__r.SVMXC__SM_Adjustment_Activity_Date__c , SVMXC__PM_Plan__r.SVMXC__SM_Condition_Type__c, SVMXC__SM_PM_Coverage__r.SVMXC__SM_Advanced_Expression__c,SVMXC__SM_Work_Order_Purpose__c, SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c, SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__r.SVMXC__Preferred_Technician__c 
                                                            FROM SVMXC__PM_Schedule__c WHERE SVMXC__SM_Status__c IN ('') AND SVMXC__PM_Plan__c IN : qualifiedPlanIdProcessMap.keySet() ORDER BY SVMXC__SM_Sequence__c ASC];

        
        Set<Id> planIdWithSchedules = new Set<Id>();
        List<ScheduleLogger> loggerList = new List<ScheduleLogger>();

        if(!scheduleOutputList.isEmpty()){  
            
            boolean IsCreateTask = test.isRunningTest() ? true : false;
            String TaskPriority = '';
            Set<Id> installedBaseIds = new Set<Id>();
            Map<Id, Date> scheduleActivityCompletionDateMap = new Map<Id, Date>();

            //One time used variables
            Map<Id,String> processedScheduleActivityFieldMap = new Map<Id,String>();    
            Set<String> activityWOFields = new Set<String>();

            if(!test.isRunningTest()){
                prevEngineSettings = new SVMXC.COMM_Utils_ManageSettings().SVMX_getSettingList('PREV004');

                if(prevEngineSettings != null){
                    if(prevEngineSettings.containsKey('SET001') && prevEngineSettings.get('SET001').equalsIgnoreCase('true')){
                        IsCreateTask = true;
                    }

                    if(prevEngineSettings.containsKey('SET002') && prevEngineSettings.get('SET002') != null){
                        TaskPriority = prevEngineSettings.get('SET002');
                    }
                }
            }

            
            Savepoint sp = Database.setSavepoint(); //Defining Save point before executing any DMLs in the engine execute

            try{
                // First loop to get the all measurable attributes for querying along with IB Ids                                                   
                for(SVMXC__PM_Schedule__c scheduleRecord : scheduleOutputList){
                    // 1. Parse Expression
                    planIdWithSchedules.add(scheduleRecord.SVMXC__PM_Plan__c);
                    if(scheduleRecord.SVMXC__SM_PM_Coverage__c != null){
                        
                        if(scheduleRecord.SVMXC__SM_Expression_Internal_Value__c != null){

                            expressionWrapper expressionJSON = expressionParser(scheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c, scheduleRecord.SVMXC__SM_Sequence__c, scheduleRecord.SVMXC__SM_Expression_Internal_Value__c);
                        }

                        installedBaseIds.add(scheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c);
                    
                    }
                }


                System.debug(LoggingLevel.DEBUG, 'No. of Technical Attributes to be queried ' + technicalAttributes.size());

                if(!technicalAttributes.isEmpty())
                    getTechnicalAttributeCurrentReadings(installedBaseIds); 

                Map<Id,SVMXC__Installed_Product__c> ibRecMap = getSchemaAttributeCurrentReadings(installedBaseIds); 

                Map<Id,SVMXC__Service_Order__c> scheduleWOMap = new Map<Id,SVMXC__Service_Order__c>();
                Set<Id> taskTemplateIds = new Set<Id>();  //To get all the Task templates
                Set<Id> mappingProcessIds = new Set<Id> ();  // To get all the Mapping process Ids
                Set<String> targetObjectSet = new Set<String>();     //To get record types Id Map   
                Map<Id, Id> coverageLatestScheduleMap = new Map<Id, Id>();  
                Map<Id, Datetime> schedulePreferredDateMap = new Map<Id, Datetime>();
                Set<Id> coverageIds = new Set<Id>();

                List<SVMXC__PM_Schedule__c> qualifiedScheduleOutput = new List<SVMXC__PM_Schedule__c>();

                /*
                 *  Looping through Schedule output again, to evaluate expressions and to get all the qualified PM Plans
                 */

                for(SVMXC__PM_Schedule__c scheduleRecord : scheduleOutputList){
                    
                    ScheduleLogger logObj = new ScheduleLogger();
                    
                    
                    logObj.strLogger = '\n' + String.valueOfGmt(system.now()) + ': PM Schedule : '+ scheduleRecord.Name;

                    if(scheduleRecord.SVMXC__SM_PM_Coverage__c != null){
                        
                        if(scheduleRecord.SVMXC__SM_Expression_Internal_Value__c != null){
                            
                            String advancedExpression;
                            if(scheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__SM_Advanced_Expression__c != null){
                                advancedExpression = scheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__SM_Advanced_Expression__c;
                            }else if(scheduleRecord.SVMXC__PM_Plan__r.SVMXC__SM_Advanced_Expression__c != null){
                                advancedExpression = scheduleRecord.SVMXC__PM_Plan__r.SVMXC__SM_Advanced_Expression__c;
                            }


                            //Sample expression - '{\"Rules\": [{\"Order\":\"1\",\"attrName\":\"Print\",\"operator\": \"EYI\",\"attrValue\":\"20\",\"datatype\":\"integer\",\"attrType\":\"Technical\"},{\"Order\":\"1\",\"attrName\":\"PaperCount\",\"operator\": \"EYD\",\"attrValue\":\"20\",\"datatype\":\"integer\",\"attrType\": \"Technical\"}]}'
                            ExpressionWrapper expressionJSON = (ExpressionWrapper) JSON.deserialize(scheduleRecord.SVMXC__SM_Expression_Internal_Value__c,ExpressionWrapper.class);

                            Map<String,String> ruleOutputMap = new Map<String,String>();
                            SVMXC__ServiceMax_Processes__c pmProcessRecord;
                            if(expressionJSON != null && expressionJSON.rules != null){
                                integer nDaysBefore = 0;

                                If(qualifiedPlanIdProcessMap.containsKey(scheduleRecord.SVMXC__PM_Plan__c)){
                                    pmProcessRecord = qualifiedPlanIdProcessMap.get(scheduleRecord.SVMXC__PM_Plan__c);
                                    
                                    logObj.processId = pmProcessRecord.Id;
                                    logObj.processName = pmProcessRecord.Name;
                                    logObj.planId = scheduleRecord.SVMXC__PM_Plan__c;
                                    logObj.planName = scheduleRecord.SVMXC__PM_Plan__r.Name;

                                    if(!test.isRunningTest()){
                                        if(scheduleRecord.SVMXC__PM_Plan__r.Owner.isActive == true){
                                            logObj.ownerIdStr = scheduleRecord.SVMXC__PM_Plan__r.OwnerId;
                                        }
                                    }else{
                                        logObj.ownerIdStr = scheduleRecord.SVMXC__PM_Plan__r.OwnerId;
                                    }

                                    nDaysBefore = (pmProcessRecord.SVMXC__Frequency__c != null) ? integer.valueof(pmProcessRecord.SVMXC__Frequency__c) : 0;
                                }

                                for(ruleExpression ruleExpRecord : expressionJSON.rules){
                                    
                                    if(ruleExpRecord.attrName != null){
                                        
                                        String uniqueIbAttributeKeyForTarget = scheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c + ruleExpRecord.attrName.trim() + scheduleRecord.SVMXC__SM_Sequence__c + ruleExpRecord.order.trim();
                                        String uniqueIbAttributeKey = scheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c + ruleExpRecord.attrName.trim();
                                        
                                        if(targetAttributeReadings.containsKey(uniqueIbAttributeKeyForTarget)){
                                            boolean ruleOutput = False;
                                            String currentReading;
                                            if(currentAttributeReadings.containsKey(uniqueIbAttributeKey)){
                                                currentReading = currentAttributeReadings.get(uniqueIbAttributeKey);
                                            }else if(ruleExpRecord.attrType.equalsIgnoreCase(ATTRIBUTE_TYPE_STRING_LITERAL)){
                                                if(ruleExpRecord.attrName.trim().equalsIgnoreCase('Today')){
                                                    DateTime dt = System.now();
                                                    String utcDt = dt.format('yyyy-MM-dd', 'UTC'); 
                                                    currentReading = utcDt;
                                                }
                                            }

                                            if(currentReading != null){
                                                String targetDateStr = targetAttributeReadings.get(uniqueIbAttributeKeyForTarget);
                                                ruleOutput = parseRule(currentReading,ruleExpRecord.operator,targetDateStr,ruleExpRecord.datatype, nDaysBefore);
                                                String booleanStr = (ruleOutput) ? 'T':'F';                                     
                                                ruleOutputMap.put(ruleExpRecord.order,booleanStr);      
                                                if(booleanStr == 'T' && ruleExpRecord.attrType.equalsIgnoreCase(ATTRIBUTE_TYPE_STRING_LITERAL) && ruleExpRecord.attrName.trim().equalsIgnoreCase('Today')){
                                                    Date convertedDate = Date.valueOf(targetDateStr);
                                                    Datetime convertedDateTime = Datetime.newInstance(convertedDate.year(), convertedDate.month(), convertedDate.day());
                                                    
                                                    if(schedulePreferredDateMap.containsKey(scheduleRecord.Id)){
                                                        Datetime tempDateTime = schedulePreferredDateMap.get(scheduleRecord.Id);
                                                        if(convertedDateTime >  tempDateTime)
                                                            convertedDateTime = tempDateTime; 
                                                    }
                                                    schedulePreferredDateMap.put(scheduleRecord.Id, convertedDateTime);
                                                }                           
                                            }else{
                                                ruleOutputMap.put(ruleExpRecord.order,'F');                                 
                                            }
                                        }

                                    }
                                }
                            }
                            
                            advancedExpression = advancedExpression.ToUpperCase();
                            advancedExpression = advancedExpression.replaceAll('AND', ' && ');
                            advancedExpression = advancedExpression.replaceAll('OR', ' || ');
                            advancedExpression = advancedExpression.replaceAll('NOT', ' ! ');

                            for(String keyStr :ruleOutputMap.keySet()){
                                advancedExpression = advancedExpression.replaceAll(keyStr, ruleOutputMap.get(keyStr));
                            }

                            if(evaluateExpression(advancedExpression)){
                                
                                logObj.status = 'Qualified';
                                logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Schedule Output Status : Qualified';

                                /*
                                    Fetching all the Coverage Ids to get the previous Schedules and its history record to find the status of previous Work Order.
                                */
                                if(scheduleRecord.SVMXC__PM_Plan__r.SVMXC__SM_Condition_Type__c != null && scheduleRecord.SVMXC__PM_Plan__r.SVMXC__SM_Condition_Type__c.equalsIgnoreCase(CONDITION_TYPE_COMPARISON) && scheduleRecord.SVMXC__SM_Sequence__c != 1){
                                    coverageIds.add(scheduleRecord.SVMXC__SM_PM_Coverage__c);
                                }
                                
                                qualifiedScheduleOutput.add(scheduleRecord);


                                coverageLatestScheduleMap.put(scheduleRecord.SVMXC__SM_PM_Coverage__c, scheduleRecord.Id);
                                SVMXC__Service_Order__c scheduleOuptutWORec = createWorkOrder(scheduleRecord);

                                /*
                                    Using this map to get the work order and PM Schedule mapped to history record, as there is no direct relationship to PM schedule 
                                    and Work Order. Using this map for pass by reference as the Work order serves primary object for creating all related records
                                */
                                scheduleWOMap.put(scheduleRecord.Id, scheduleOuptutWORec);

                                if(pmProcessRecord != null){
                                    
                                    //Work Order to Case
                                    if(pmProcessRecord.SVMXC__Process__c != null && pmProcessRecord.SVMXC__Include_Parent__c)
                                        mappingProcessIds.add(pmProcessRecord.SVMXC__Process__c);

                                    //Template to Task
                                    if(pmProcessRecord.SVMXC__Process1__c != null)
                                        mappingProcessIds.add(pmProcessRecord.SVMXC__Process1__c);

                                    //Template to Work Order Parts  
                                    if(pmProcessRecord.SVMXC__Process2__c != null)  
                                        mappingProcessIds.add(pmProcessRecord.SVMXC__Process2__c);          

                                    //IB to WorkOrder   
                                    if(pmProcessRecord.SVMXC__Node_Parent__c != null)   
                                        mappingProcessIds.add(pmProcessRecord.SVMXC__Node_Parent__c);       

                                    //Schedule Definition to Work Order 
                                    if(pmProcessRecord.SVMXC__Submodule__c != null)
                                        mappingProcessIds.add(pmProcessRecord.SVMXC__Submodule__c); 
                                
                                    if(pmProcessRecord.SVMXC__Target_Object_Name__c != null)            
                                        targetObjectSet.add(pmProcessRecord.SVMXC__Target_Object_Name__c);

                                }   

                                if(IsCreateTask){
                                    //scheduleOuptutWORec.SVMXC__PM_Tasks_Created__c = true;
                                    if(scheduleRecord.SVMXC__SM_Work_Order_Purpose__c != null && !taskTemplateIds.contains(scheduleRecord.SVMXC__SM_Work_Order_Purpose__c)){
                                        taskTemplateIds.add(scheduleRecord.SVMXC__SM_Work_Order_Purpose__c);
                                    }else if(scheduleRecord.SVMXC__PM_Plan__r.SVMXC__Task_Template__c != null && !taskTemplateIds.contains(scheduleRecord.SVMXC__PM_Plan__r.SVMXC__Task_Template__c)){
                                        taskTemplateIds.add(scheduleRecord.SVMXC__PM_Plan__r.SVMXC__Task_Template__c);
                                    }               
                                }           
                            }else{
                                logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Schedule Output Status : Not Qualified';
                                logObj.status = 'Not Qualified';
                            }
                        }

                    }   

                    scheduleLogMap.put(scheduleRecord.Id, logObj);

                }

                /*
                    Querying the previous schedule record and its related history record. G
                    Fetching the latest one using the map previousScheduleHistoryMap
                */

                Map<Id, SVMXC__PM_Schedule__c> previousScheduleHistoryMap;

                if(coverageIds != null){
                    
                    previousScheduleHistoryMap = new Map<Id, SVMXC__PM_Schedule__c>();
                    
                    for(SVMXC__PM_Schedule__c pmScheduleRecord : [SELECT Id, SVMXC__SM_Status__c,SVMXC__SM_PM_Coverage__c, (SELECT Id, SVMXC__Work_Order_Created_on__c,SVMXC__Work_Order_Closed_on__c FROM SVMXC__PM_History__r) FROM SVMXC__PM_Schedule__c WHERE 
                                                                      SVMXC__SM_Status__c IN ('Work Order Created','Work Order Done') AND SVMXC__SM_PM_Coverage__c IN : coverageIds ORDER BY CreatedDate]){

                        previousScheduleHistoryMap.put(pmScheduleRecord.SVMXC__SM_PM_Coverage__c, pmScheduleRecord);
                    }
                }                                                     

                scheduleOutputList.clear();  //Clearing Schedule Output, now we have qualifiedScheduleOutput for further processing

                /*
                    Querying all the templates in one shot
                    TBD - Query all the fields available on Template and Required Parts. As there can be any field from these object used in the PM process mapping.
                */

                Map<Id,SVMXC__Task_Template__c> taskTemplateIdMap; //Map to hold all the tasks and required parts under a template

                if(!taskTemplateIds.isEmpty()){

                    Schema.DescribeSobjectResult objResult = getFieldDescribe('SVMXC__Task_Template__c');
                    map<String, Schema.SObjectField> mapFieldDesc = objResult.fields.getMap();

                    String templateQueryFields= getQueryFieldString(mapFieldDesc);

                    objResult = getFieldDescribe('SVMXC__Required_Part__c');
                    mapFieldDesc = objResult.fields.getMap();       

                    String reqPartsQueryFields= getQueryFieldString(mapFieldDesc);          
                    
                    String templateQueryString = 'SELECT Id, (SELECT ' + templateQueryFields + ' FROM SVMXC__Task_templates__r WHERE RecordType.Name = \'Tasks\'), (SELECT ' + reqPartsQueryFields + ' FROM SVMXC__Required_Parts__r ) FROM ' + 
                                                                      + 'SVMXC__Task_Template__c WHERE RecordType.Name = \'Templates\' AND ID IN : taskTemplateIds ';
                    
                    List<SVMXC__Task_Template__c>   taskTemplateRecords = (List<SVMXC__Task_Template__c>) Database.query(templateQueryString);                                                                

                    taskTemplateIdMap = new Map<Id,SVMXC__Task_Template__c>(taskTemplateRecords );
                    
                }


                /*
                    Querying all the Mapping Process records in one shot
                */

                Map<Id,SVMXC__ServiceMax_Processes__c> mappingProcessRecordMap; //Map to hold all the mapping process records
                

                if(!mappingProcessIds.isEmpty()){
                    mappingProcessRecordMap = new Map<Id,SVMXC__ServiceMax_Processes__c>([Select  Name, Id, (SELECT Id, Name, SVMXC__Source_Field_Name__c, SVMXC__Display_Value__c, SVMXC__Target_Field_Name__c, SVMXC__Preference_2__c, SVMXC__Preference_3__c 
                                                                                            FROM SVMXC__SVMX_Config_Data2__r) From SVMXC__ServiceMax_Processes__c  where Id IN : mappingProcessIds]);
                }           


                targetObjectSet.add('SVMXC__Service_Order__c');
                targetObjectSet.add('SVMXC__Service_Order_Line__c');
                Set<Id> technicianIds = new Set<Id>();
                getTargetObjRecordTypes(targetObjectSet);  //To get record type IDs

                System.debug(LoggingLevel.INFO, 'Qualified Schedule Output size ' + qualifiedScheduleOutput.size());

                //Looping through qualified schedule output again to create work order with mappings
                for(SVMXC__PM_Schedule__c scheduleRecord : qualifiedScheduleOutput){
                
                    ScheduleLogger logObj = scheduleLogMap.get(scheduleRecord.Id);
                    
                    if(scheduleRecord.Id == coverageLatestScheduleMap.get(scheduleRecord.SVMXC__SM_PM_Coverage__c)){


                        if(scheduleWOMap.containsKey(scheduleRecord.Id) && qualifiedPlanIdProcessMap.containsKey(scheduleRecord.SVMXC__PM_Plan__c)){

                            

                            //if(qualifiedPlanIdProcessMap.containsKey(scheduleRecord.SVMXC__PM_Plan__c)){
                                
                            SVMXC__ServiceMax_Processes__c pmProcess = qualifiedPlanIdProcessMap.get(scheduleRecord.SVMXC__PM_Plan__c);

                            /*
                                If its criteria/comparison based PM, checking the previous schedule work order status before creating the next Work order.
                            */
                            if(scheduleRecord.SVMXC__PM_Plan__r.SVMXC__SM_Condition_Type__c != null && scheduleRecord.SVMXC__PM_Plan__r.SVMXC__SM_Condition_Type__c.equalsIgnoreCase(CONDITION_TYPE_COMPARISON)){

                                System.debug(LoggingLevel.INFO, 'Condition Type ' + scheduleRecord.SVMXC__PM_Plan__r.SVMXC__SM_Condition_Type__c);

                                SVMXC__PM_History__c historyRecord;
                                if(previousScheduleHistoryMap.containsKey(scheduleRecord.SVMXC__SM_PM_Coverage__c)){
                                        
                                    SVMXC__PM_Schedule__c previousSchedule = previousScheduleHistoryMap.get(scheduleRecord.SVMXC__SM_PM_Coverage__c);

                                    if(previousSchedule.SVMXC__PM_History__r != null && previousSchedule.SVMXC__PM_History__r.size() > 0){

                                        historyRecord = previousSchedule.SVMXC__PM_History__r[0];
                                        System.debug(LoggingLevel.INFO, 'History Record found ' + historyRecord);
                                    
                                    }
                                }

                                /*
                                    Defect :BAC-2828 
                                    Below condition should be applicable only if the previous Work Order is still open.  
                                */  
                                if(historyRecord != null && historyRecord.SVMXC__Work_Order_Closed_on__c == null){
                                    
                                    /*
                                        If PM Process is configured to create new work order irrespective of previous work order closure, calculating the difference from the date of creation till today
                                        else creating next work order only if the previous one is closed.
                                    */
                                    if(!pmProcess.SVMXC__SM_Do_Not_Create_New_WO__c){ 

                                        integer nDays = (pmProcess.SVMXC__SM_Do_Not_Create_WO_Within__c != null) ? integer.valueOf(pmProcess.SVMXC__SM_Do_Not_Create_WO_Within__c) : 0;
                                        integer diff = (historyRecord.SVMXC__Work_Order_Created_on__c != null) ?  date.valueOf(historyRecord.SVMXC__Work_Order_Created_on__c).daysBetween(System.today()) : 0;
                                        
                                        System.debug(LoggingLevel.INFO, 'Difference :' + diff + ' nDays ' + nDays);

                                        if(diff < nDays){

                                            scheduleWOMap.remove(scheduleRecord.Id);
                                            continue;
                                        }
 
                                    }else{
                                            scheduleWOMap.remove(scheduleRecord.Id);
                                            continue;
                                    }
                                }
                            }

                            SVMXC__Installed_Product__c ibRecord;
                            SVMXC__Service_Order__c workOrderRec = scheduleWOMap.get(scheduleRecord.Id);
                            logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Applying Mapping';

                            if(mappingProcessRecordMap != null){

                                if(ibRecMap.containsKey(scheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c)){
                                    ibRecord = ibRecMap.get(scheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c);
                                }

                                SVMXC__ServiceMax_Processes__c processRecord; 

                                //IB to WO Mapping
                                if(pmProcess.SVMXC__Node_Parent__c != null && mappingProcessRecordMap.containsKey(pmProcess.SVMXC__Node_Parent__c)){

                                    processRecord = mappingProcessRecordMap.get(pmProcess.SVMXC__Node_Parent__c);

                                    if(processRecord != null){

                                        if(ibRecord != null){
                                            logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Applying IB to Work Order Mapping with Name ' + processRecord.Name;
                                            workOrderRec = (SVMXC__Service_Order__c)applyMapping(processRecord, 'SVMXC__Service_Order__c', (sObject)ibRecord, (sObject)workOrderRec);
                                            
                                            workOrderRec.SVMXC__Preferred_Start_Time__c = System.now();

                                            if(schedulePreferredDateMap.containsKey(scheduleRecord.Id)){
                                                workOrderRec.SVMXC__Preferred_Start_Time__c = schedulePreferredDateMap.get(scheduleRecord.Id);
                                            }
                                        }

                                    }

                                }

                            }

                            if(pmProcess.SVMXC__Assign_Work_Order_To__c != null){
                                
                                if(pmProcess.SVMXC__Assign_Work_Order_To__c == 'Primary Technician'){
                                    
                                    if(ibRecord != null && ibRecord.SVMXC__Preferred_Technician__c != null && ibRecord.SVMXC__Preferred_Technician__r.SVMXC__Salesforce_User__c != null
                                        && ibRecord.SVMXC__Preferred_Technician__r.SVMXC__Salesforce_User__r.IsActive == true){
                                        logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Assigning Work Order to Primary Technician with Id : ' + ibRecord.SVMXC__Preferred_Technician__c; 
                                        workOrderRec.SVMXC__Group_Member__c = ibRecord.SVMXC__Preferred_Technician__c;
                                        technicianIds.add(ibRecord.SVMXC__Preferred_Technician__c);
                                    }   
                                }else if(pmProcess.SVMXC__Assign_Work_Order_To__c == 'Team' && pmProcess.SVMXC__Assign_To_Service_Team__c != null){
                                    logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Assigning Work Order to Service Team with Id : ' + pmProcess.SVMXC__Assign_To_Service_Team__c; 
                                    workOrderRec.SVMXC__Service_Group__c = pmProcess.SVMXC__Assign_To_Service_Team__c;
                                }else if(pmProcess.SVMXC__Assign_Work_Order_To__c  == 'Dispatcher' && pmProcess.SVMXC__Assign_To_Dispatcher__c != NULL){
                                    logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Assigning Work Order to Dispatcher with Id : ' + pmProcess.SVMXC__Assign_To_Dispatcher__c; 
                                    workOrderRec.OwnerId = pmProcess.SVMXC__Assign_To_Dispatcher__c;
                                }else if(pmProcess.SVMXC__Assign_Work_Order_To__c == 'Technician' && pmProcess.SVMXC__Assign_To_Technician__c != NULL){
                                    logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Assigning Work Order to Technician : ' + pmProcess.SVMXC__Assign_To_Technician__c; 
                                    workOrderRec.SVMXC__Group_Member__c = pmProcess.SVMXC__Assign_To_Technician__c;
                                    technicianIds.add(pmProcess.SVMXC__Assign_To_Technician__c);
                                }else if(pmProcess.SVMXC__Assign_Work_Order_To__c == 'Queue' && pmProcess.SVMXC__Assign_To_Queue__c != NULL){
                                    logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Assigning Work Order to Queue : ' + pmProcess.SVMXC__Assign_To_Queue__c; 
                                    workOrderRec.OwnerId = pmProcess.SVMXC__Assign_To_Queue__c;
                                }
                            }
                            //}
                        }
                    }else {
                        logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Schedule Output Status : Skipped';
                        logObj.status = 'Skipped';
                        scheduleWOMap.remove(scheduleRecord.Id);
                        scheduleRecord.SVMXC__SM_Status__c = STATUS_WO_CANCELLED;
                    }
                    scheduleOutputList.add(scheduleRecord);
                    scheduleLogMap.put(scheduleRecord.Id, logObj);
                }

                
                qualifiedScheduleOutput.clear();
                qualifiedScheduleOutput.addAll(scheduleOutputList);
                scheduleOutputList.clear();

                if(!scheduleWOMap.values().isEmpty()){
                    
                    /*
                        To-Do : Use database.insert method to support partial success
                    */

                    Database.SaveResult[] saveResultForWOs = Database.insert(scheduleWOMap.values(), false);

                }


                List<sObject> relatedsObjectList = new List<sObject>();
                Map<Id,Case> workOrderIdcaseMap = new Map<Id,Case>();
                Map<Id,SVMXC__Service_Group_Members__c> groupMemberMap;
                List<SVMXC__PM_Schedule__c> newScheduleList;

                if(!technicianIds.isEmpty()){
                    groupMemberMap = new Map<Id,SVMXC__Service_Group_Members__c>([Select Id, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Active__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive, 
                                                                                    SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Salesforce_User__r.TimeZoneSidKey from 
                                                                                    SVMXC__Service_Group_Members__c where ID IN: technicianIds AND SVMXC__Active__c = true]);
                }


                /*
                    Looping one last time after work order creation to create all the associated records like Task, Work Order lines, Case 
                    and applying related mappings
                */
                System.debug(LoggingLevel.INFO, 'Qualified Schedule Output size After' + qualifiedScheduleOutput.size());

                for(SVMXC__PM_Schedule__c scheduleRecord : qualifiedScheduleOutput){
                    
                    ScheduleLogger logObj = scheduleLogMap.get(scheduleRecord.Id);              

                    if(scheduleWOMap.containsKey(scheduleRecord.Id)){
                        SVMXC__Service_Order__c  workOrderRec = scheduleWOMap.get(scheduleRecord.Id);
                        
                        if(workOrderRec.Id != null){
                            logObj.workOrderCreated = true; 
                            logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Work Order ' + workOrderRec.Id + ' created successfully ';
                            scheduleRecord.SVMXC__SM_Status__c = STATUS_WO_CREATED;
                            SVMXC__PM_History__c pmHistoryRec = createPMHistory(scheduleRecord);
                            pmHistoryRec.SVMXC__Work_Order__c = workOrderRec.Id;
                            pmHistoryRec.SVMXC__Work_Order_Created_on__c = workOrderRec.SVMXC__Preferred_Start_Time__c;
                            //pmScheduleUpdateList.add(scheduleRecord);

                            

                            if(qualifiedPlanIdProcessMap.containsKey(scheduleRecord.SVMXC__PM_Plan__c)){
                                SVMXC__ServiceMax_Processes__c pmProcess = qualifiedPlanIdProcessMap.get(scheduleRecord.SVMXC__PM_Plan__c);
                                //pmProcess.SVMXC__Process1__c  - Mapping Id for Task
                                //pmProcess.SVMXC__Target_Object_Name__c - Target object for mapping task template
                                

                                /*
                                    BAC-2273 : Enhacement to support new operators.
                                    Creates a next Schedule for PM Plan of Type Criteria / Comparison Based after processing the current one.
                                */  
                                if(scheduleRecord.SVMXC__PM_Plan__r.SVMXC__SM_Condition_Type__c != null && scheduleRecord.SVMXC__PM_Plan__r.SVMXC__SM_Condition_Type__c.equalsIgnoreCase(CONDITION_TYPE_COMPARISON)){
                                    SVMXC__PM_Schedule__c criteriaScheduleRecord = new SVMXC__PM_Schedule__c();
                                    criteriaScheduleRecord.SVMXC__PM_Plan__c = scheduleRecord.SVMXC__PM_Plan__c;
                                    criteriaScheduleRecord.SVMXC__SM_Expression_Internal_Value__c = scheduleRecord.SVMXC__SM_Expression_Internal_Value__c;
                                    criteriaScheduleRecord.SVMXC__SM_PM_Coverage__c = scheduleRecord.SVMXC__SM_PM_Coverage__c;
                                    criteriaScheduleRecord.SVMXC__SM_Sequence__c = scheduleRecord.SVMXC__SM_Sequence__c + 1;
                                    criteriaScheduleRecord.SVMXC__SM_Work_Order_Purpose__c = scheduleRecord.SVMXC__SM_Work_Order_Purpose__c;
                                    criteriaScheduleRecord.SVMXC__SM_Expression_Display_Value__c = scheduleRecord.SVMXC__SM_Expression_Display_Value__c;
                                    criteriaScheduleRecord.SVMXC__SM_Advanced_Expression__c = scheduleRecord.SVMXC__SM_Advanced_Expression__c;

                                    logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Creating Follow up Schedule for the scheduleRecord ' + scheduleRecord.Name;

                                    if(newScheduleList == null){
                                        newScheduleList = new List<SVMXC__PM_Schedule__c>();
                                    }

                                    newScheduleList.add(criteriaScheduleRecord);

                                }
                                sObject taskObjectRecord;
                                Id taskTemplateId;

                                if(scheduleRecord.SVMXC__SM_Work_Order_Purpose__c != null){
                                    taskTemplateId = scheduleRecord.SVMXC__SM_Work_Order_Purpose__c;
                                }else if(scheduleRecord.SVMXC__PM_Plan__r.SVMXC__Task_Template__c != null){
                                    taskTemplateId = scheduleRecord.SVMXC__PM_Plan__r.SVMXC__Task_Template__c; 
                                }
                                
                                if(mappingProcessRecordMap != null){

                                    SVMXC__ServiceMax_Processes__c processRecord; 
                                    
                                    if(taskTemplateId != null && taskTemplateIdMap != null && taskTemplateIdMap.containsKey(taskTemplateId)){

                                        SVMXC__Task_Template__c templateRec = new SVMXC__Task_Template__c ();

                                        if(taskTemplateIdMap.get(taskTemplateId) != null){
                                            templateRec = taskTemplateIdMap.get(taskTemplateId);
                                        }   


                                        //Task Creation
                                        if(IsCreateTask && pmProcess.SVMXC__Target_Object_Name__c != null && pmProcess.SVMXC__Process1__c != null && mappingProcessRecordMap.containsKey(pmProcess.SVMXC__Process1__c) ){
                                            


                                            processRecord = mappingProcessRecordMap.get(pmProcess.SVMXC__Process1__c);
                                            
                                            if(processRecord != null){
                                                

                                                logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Creating ' + pmProcess.SVMXC__Target_Object_Name__c + ' Records applying Mapping with Name ' + processRecord.Name;

                                                for(SVMXC__Task_Template__c taskRecord : templateRec.SVMXC__Task_templates__r){

                                                    taskObjectRecord = applyMapping(processRecord, pmProcess.SVMXC__Target_Object_Name__c, (sObject)taskRecord, null);

                                                    if(taskObjectRecord != null){
                                                        ////TBD - Create Task only if there is owner
                                                        if(pmProcess.SVMXC__Target_Object_Name__c == 'Task'){
                                                            if(workOrderRec.SVMXC__Group_Member__c != null && groupMemberMap.containsKey(workOrderRec.SVMXC__Group_Member__c)){
                                                                SVMXC__Service_Group_Members__c groupRec = groupMemberMap.get(workOrderRec.SVMXC__Group_Member__c);
                                                                
                                                                if(groupRec.SVMXC__Salesforce_User__c != null){
                                                                    taskObjectRecord.put('WhatId', workOrderRec.Id);
                                                                    taskObjectRecord.put('OwnerId',groupRec.SVMXC__Salesforce_User__c);
                                                                    //Below condition is changed for fixing defect BAC-3997
                                                                    //if(taskRecord.SVMXC__Priority__c == null )
                                                                    if(taskObjectRecord.get('Priority') == null)
                                                                        taskObjectRecord.put('Priority', TaskPriority);
                                                                    if(taskRecord.SVMXC__Task_Title__c != null)
                                                                        taskObjectRecord.put('Subject', taskRecord.SVMXC__Task_Title__c);

                                                                    workOrderRec.SVMXC__PM_Tasks_Created__c = true;        
                                                                    relatedsObjectList.add(taskObjectRecord);    
                                                                }
                                                            }
                                                        }else{
                                                            taskObjectRecord.put(pmProcess.SVMXC__APL_Field_Name__c, workOrderRec.Id);
                                                            workOrderRec.SVMXC__PM_Tasks_Created__c = true;
                                                            relatedsObjectList.add(taskObjectRecord);
                                                        }

                                                        
                                                    }
                                                }   

                                            }

                                        }

                                        //Work Order Parts Creation
                                        if(pmProcess.SVMXC__Process2__c != null && mappingProcessRecordMap.containsKey(pmProcess.SVMXC__Process2__c)){

                                            processRecord = mappingProcessRecordMap.get(pmProcess.SVMXC__Process2__c);

                                            if(processRecord != null){
                                                
                                                logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Creating Work Order Line Records applying Mapping with Name ' + processRecord.Name;

                                                for(SVMXC__Required_Part__c requiredPartRec : templateRec.SVMXC__Required_Parts__r){
                                                    taskObjectRecord = applyMapping(processRecord, 'SVMXC__Service_Order_Line__c', (sObject)requiredPartRec, null);                                     

                                                    if(taskObjectRecord != null){
                                                        taskObjectRecord.put('SVMXC__Service_Order__c', workOrderRec.Id);       
                                                        relatedsObjectList.add(taskObjectRecord);
                                                    }                                   
                                                }
                                                
                                            }
                                        }
                                    }


                                    //Work Order to Case
                                    if(pmProcess.SVMXC__Process__c != null && mappingProcessRecordMap.containsKey(pmProcess.SVMXC__Process__c) && pmProcess.SVMXC__Include_Parent__c == true){
                                        
                                        processRecord = mappingProcessRecordMap.get(pmProcess.SVMXC__Process__c);

                                        if(processRecord != null){

                                            logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Creating Case applying Mapping with Name ' + processRecord.Name;

                                            taskObjectRecord = applyMapping(processRecord, 'Case', (sObject)workOrderRec, null);                                        

                                            if(taskObjectRecord != null){

                                                if(pmProcess.SVMXC__Assign_Case_To__c != null){
                                                    taskObjectRecord.put('SVMXC__PM_Plan__c',scheduleRecord.SVMXC__PM_Plan__c);
                                                    taskObjectRecord.put('SVMXC__Is_PM_Case__c', true);
                                                        
                                                        if(pmProcess.SVMXC__Assign_Case_To__c == 'User' && pmProcess.SVMXC__Case_Assign_To_User__c != NULL)
                                                           taskObjectRecord.put('OwnerId', pmProcess.SVMXC__Case_Assign_To_User__c);
                                                        else if(pmProcess.SVMXC__Assign_Case_To__c == 'Queue' && pmProcess.SVMXC__Case_Assign_To_Queue__c != NULL)
                                                            taskObjectRecord.put('OwnerId', pmProcess.SVMXC__Case_Assign_To_Queue__c);                                                  
                                                }
                                                
                                                workOrderIdcaseMap.put(workOrderRec.Id, (Case)taskObjectRecord);
                                            }                                   
                                        }
                                    } 
                                    


                                }

                            }   
                            
                            //pmHistoryList.add(pmHistoryRec);                                  
                            relatedsObjectList.add((sObject)pmHistoryRec);
                        }else{
                            logObj.workOrderCreated = false; 
                            logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ': Work Order creation Failed';
                            scheduleRecord.SVMXC__SM_Status__c = STATUS_WO_FAILED;
                        }   
                    }   

                    scheduleLogMap.put(scheduleRecord.Id,logObj);                       
                    
                }

                if(newScheduleList != null){
                    qualifiedScheduleOutput.addAll(newScheduleList);
                }

                //pmHistoryList = (List<SVMXC__PM_History__c>)dMLInsert((List<sObject>)pmHistoryList);

                relatedsObjectList = dMLInsert(relatedsObjectList);
                //List<SVMXC__Service_Order__c> workOrderUpdateList = new List<SVMXC__Service_Order__c>();

                if(!workOrderIdcaseMap.values().isEmpty()){
                    insert workOrderIdcaseMap.values();
                    
                    for(SVMXC__Service_Order__c workOrderRec : scheduleWOMap.values()){
                        if(workOrderIdcaseMap.containsKey(workOrderRec.Id)){
                            System.debug(LoggingLevel.DEBUG, workOrderRec);
                            Case caseRecord = workOrderIdcaseMap.get(workOrderRec.Id);
                            workOrderRec.SVMXC__Case__c = caseRecord.Id;
                            //workOrderUpdateList.add(workOrderRec);
                        }
                    }
                }

                if(!scheduleWOMap.values().isEmpty()){
                    update scheduleWOMap.values();
                }

                if(!qualifiedScheduleOutput.isEmpty()){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(qualifiedScheduleOutput, COMM_SecurityUtils.Access.Upsertable)){
                        upsert qualifiedScheduleOutput; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED //Changed from update to upsert as there will be new set of records inserted for Criteria/Comparison Based
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
            }
            catch(Exception ex){
                Database.rollback(sp);
                throw ex;
            }
        }   

        for(Id planId : qualifiedPlanIdProcessMap.keySet()){
            if(!planIdWithSchedules.contains(planId)){
                ScheduleLogger logObj = new ScheduleLogger();
                logObj.planId = planId;
                logObj.planName = 
                logObj.status = 'Success';
                logObj.processId = qualifiedPlanIdProcessMap.get(planId).Id;
                logObj.strLogger = '\n' + String.valueOfGmt(system.now()) + ': ' + 'No valid PM Schedule (Condition Based) is available for this Preventive Maintenance Plan.';
                loggerList.add(logObj);
            }
        }

        if(!scheduleLogMap.values().isEmpty()){
            loggerList.addAll(scheduleLogMap.values());
        }

        return loggerList;
    }


    void getTargetObjRecordTypes(Set<String> objectsNameSet){
        
        for(RecordType recordTypeRec : [SELECT Id, Name FROM RecordType WHERE sObjectType IN: objectsNameSet AND IsActive = true]){
            recordTypeIDMap.put(recordTypeRec.Name, recordTypeRec.Id);
        }
    }

    sObject applyMapping(SVMXC__ServiceMax_Processes__c mappingProcess, String targetObjName, sObject sourceSobject, sObject targetSobject){
        Schema.DescribeSobjectResult objResult = getFieldDescribe(targetObjName);
        map<String, Schema.SObjectField> mapFieldDesc = objResult.fields.getMap();
        targetSobject = (targetSobject != null) ? targetSobject: objResult.getSobjectType().newSObject();
        
        for(SVMXC__ServiceMax_Config_Data__c fieldMappingRec : mappingProcess.SVMXC__SVMX_Config_Data2__r){
            
            //Value Mapping
            if(fieldMappingRec.SVMXC__Source_Field_Name__c != null && fieldMappingRec.SVMXC__Display_Value__c != null){
                targetSobject.put(fieldMappingRec.SVMXC__Source_Field_Name__c,fieldMappingRec.SVMXC__Display_Value__c);
            }

            if(fieldMappingRec.SVMXC__Target_Field_Name__c != null){

                if(fieldMappingRec.SVMXC__Target_Field_Name__c == 'RecordTypeId'){
                    
                    if(fieldMappingRec.SVMXC__Display_Value__c != null){
                    
                        if(recordTypeIDMap.containsKey(fieldMappingRec.SVMXC__Display_Value__c))
                            targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c, recordTypeIDMap.get(fieldMappingRec.SVMXC__Display_Value__c));

                    }else if(fieldMappingRec.SVMXC__Source_Field_Name__c != null && sourceSobject.get(fieldMappingRec.SVMXC__Source_Field_Name__c )!= null){

                        targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c, String.valueOf(sourceSobject.get(fieldMappingRec.SVMXC__Source_Field_Name__c)));
                    }   
                }else {

                    if(fieldMappingRec.SVMXC__Source_Field_Name__c != null && sourceSobject.get(fieldMappingRec.SVMXC__Source_Field_Name__c) != null && String.valueof(sourceSobject.get(fieldMappingRec.SVMXC__Source_Field_Name__c)) != null){

                        targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,sourceSobject.get(fieldMappingRec.SVMXC__Source_Field_Name__c));
                    }else if(fieldMappingRec.SVMXC__Source_Field_Name__c != null && sourceSobject.get(fieldMappingRec.SVMXC__Source_Field_Name__c) == null && fieldMappingRec.SVMXC__Preference_2__c != null && String.valueof(sourceSobject.get(fieldMappingRec.SVMXC__Preference_2__c)) != null){

                        targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,sourceSobject.get(fieldMappingRec.SVMXC__Preference_2__c));
                    }else if(fieldMappingRec.SVMXC__Source_Field_Name__c != null && sourceSobject.get(fieldMappingRec.SVMXC__Source_Field_Name__c) == null && fieldMappingRec.SVMXC__Preference_2__c != null && String.valueof(sourceSobject.get(fieldMappingRec.SVMXC__Preference_2__c)) == null 
                             && fieldMappingRec.SVMXC__Preference_3__c != null && String.valueof(sourceSobject.get(fieldMappingRec.SVMXC__Preference_3__c)) != null){

                        targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,sourceSobject.get(fieldMappingRec.SVMXC__Preference_3__c));
                    }

                    if(fieldMappingRec.SVMXC__Source_Field_Name__c  == null && fieldMappingRec.SVMXC__Preference_2__c == null  && fieldMappingRec.SVMXC__Preference_3__c == null && fieldMappingRec.SVMXC__Display_Value__c != null && mapFieldDesc.containskey(fieldMappingRec.SVMXC__Target_Field_Name__c)){

                        Schema.DescribeFieldResult f = mapFieldDesc.get(fieldMappingRec.SVMXC__Target_Field_Name__c).getDescribe();     

                        if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency) && f.isCreateable()){
                            
                            if(double.valueOf(fieldMappingRec.SVMXC__Display_Value__c) != null ){
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,(double.valueOf(fieldMappingRec.SVMXC__Display_Value__c)));
                            }   
                        }else if(f.getType() == schema.Displaytype.Integer && f.isCreateable()){

                            if(Integer.valueof(fieldMappingRec.SVMXC__Display_Value__c)!= null){
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,Integer.valueof(fieldMappingRec.SVMXC__Display_Value__c));
                            }   
                        }else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable()){
                            
                            if(Boolean.valueof(fieldMappingRec.SVMXC__Display_Value__c)!= null){
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,Boolean.valueof(fieldMappingRec.SVMXC__Display_Value__c));
                            }   
                        }else if(f.getType() == schema.Displaytype.DateTime && f.isCreateable()){
                            
                            if(fieldMappingRec.SVMXC__Display_Value__c.touppercase() == 'TODAY'){
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));
                            }else if(fieldMappingRec.SVMXC__Display_Value__c.touppercase() == 'YESTERDAY'){
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));
                            }else if(fieldMappingRec.SVMXC__Display_Value__c.touppercase() == 'TOMORROW'){
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));
                            }else if(fieldMappingRec.SVMXC__Display_Value__c.touppercase() == 'NOW'){
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,system.now());
                            }else{           
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,DateTime.valueof(fieldMappingRec.SVMXC__Display_Value__c));
                            }
                                    
                        }else if(f.getType() == schema.Displaytype.Date && f.isCreateable()){
                            
                            if(fieldMappingRec.SVMXC__Display_Value__c.touppercase() == 'TODAY'){
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,system.today());
                            }else if(fieldMappingRec.SVMXC__Display_Value__c.touppercase() == 'YESTERDAY'){
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,system.today() - 1);
                            }else if(fieldMappingRec.SVMXC__Display_Value__c.touppercase() == 'TOMORROW'){
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,system.today() + 1);
                            }else{           
                                
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,Date.valueof(fieldMappingRec.SVMXC__Display_Value__c));
                            }
                        }else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable()){
                            
                            if(String.valueof(fieldMappingRec.SVMXC__Display_Value__c) != null)
                            {
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,String.valueof(fieldMappingRec.SVMXC__Display_Value__c));
                            }
                        }else if((String)fieldMappingRec.SVMXC__Display_Value__c != null && f.isCreateable()){
                        
                                targetSobject.put(fieldMappingRec.SVMXC__Target_Field_Name__c,(String)fieldMappingRec.SVMXC__Display_Value__c);
                        }
                    }
                }
            }
        }

        return targetSobject;
    }

    Schema.DescribeSobjectResult getFieldDescribe(String objName){
        Schema.DescribeSobjectResult[] objResults = Schema.describeSObjects(new String[]{objName});
        return objResults[0];
    }

    List<sObject> dMLInsert(List<sObject> sObjList){
        if(!sObjList.isEmpty()){
            try{
                insert sObjList;
            }catch(DmlException ex) {
                throw ex;
            }
        }

        return sObjList;
    }

    SVMXC__Service_Order__c createWorkOrder(SVMXC__PM_Schedule__c scheduleRecord){
        SVMXC__Service_Order__c pMCoverageWO = new SVMXC__Service_Order__c();
        pMCoverageWO.SVMXC__PM_Plan__c = scheduleRecord.SVMXC__PM_Plan__c;
        pMCoverageWO.SVMXC__Component__c = scheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c;
        pMCoverageWO.SVMXC__Is_PM_Work_Order__c = true;
        return pMCoverageWO;
    }

    SVMXC__PM_History__c createPMHistory(SVMXC__PM_Schedule__c scheduleRecord){
        SVMXC__PM_History__c pMWOHistory = new SVMXC__PM_History__c();
        pMWOHistory.SVMXC__PM_Plan__c = scheduleRecord.SVMXC__PM_Plan__c;
        pMWOHistory.SVMXC__Installed_Product__c = scheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c;
        pMWOHistory.SVMXC__PM_Coverage__c = scheduleRecord.SVMXC__SM_PM_Coverage__c;
        pMWOHistory.SVMXC__SM_PM_Schedule__c = scheduleRecord.Id;
        return pMWOHistory;
    }   

    boolean parseRule(String operand, String operator, String value, String dataType, integer nDaysBefore){
        try{
            if(operand == '' || value == ''){
                return false;
            }

            if(dataType.equalsIgnoreCase('Number')){
                if(operator.equalsIgnoreCase('EYI')){
                    if(Double.valueOf(operand) >= Double.valueOf(value)){
                        return true;
                    }
                }else if(operator.equalsIgnoreCase('EYD')){
                    if(Double.valueOf(operand) <= Double.valueOf(value)){
                        return true;
                    }
                }else if(operator.equalsIgnoreCase('eq')){
                    if(Double.valueOf(operand) == Double.valueOf(value)){
                        return true;
                    }
                }else if(operator.equalsIgnoreCase('gt')){
                    if(Double.valueOf(operand) > Double.valueOf(value)){
                        return true;
                    }
                }else if(operator.equalsIgnoreCase('lt')){
                    if(Double.valueOf(operand) < Double.valueOf(value)){
                        return true;
                    }
                }
            }else if(dataType.equalsIgnoreCase('Date')){
                /*
                      DateTime dt = DateTime.parse('11/6/2014 12:00 AM');
                      String utcDt = dt.format('yyyy-MM-dd', 'UTC'); 
                */
                Date dateVal = Date.valueOf(operand);
                dateVal = dateVal.addDays(nDaysBefore);

                if(operator.equalsIgnoreCase('EYI')){
                    
                    if(dateVal >= Date.valueOf(value)){
                        return true;
                    }
                }else if(operator.equalsIgnoreCase('eq')){
                    if(dateVal == Date.valueOf(value)){
                        return true;
                    }
                }else if(operator.equalsIgnoreCase('gt')){
                    if(dateVal > Date.valueOf(value)){
                        return true;
                    }
                }else if(operator.equalsIgnoreCase('lt')){
                    if(dateVal < Date.valueOf(value)){
                        return true;
                    }
                }
            }else if(dataType.equalsIgnoreCase('Picklist') || dataType.equalsIgnoreCase('text')){

                if(operand.equalsIgnoreCase(value)){
                    return true;
                }

            }
        }catch(Exception ex){
            throw ex;
        }

        return False;
    }


    boolean evaluateExpression(String advancedExpression){
        advancedExpression = advancedExpression.trim();
        advancedExpression = advancedExpression.replaceAll(' ','');
        String tempAdvancedExp = '';
        
        System.debug(LoggingLevel.INFO,'advancedExpression Entry : ' + advancedExpression);

        do
        {
            tempAdvancedExp = advancedExpression;
            advancedExpression  = advancedExpression.replace('(F)','F').replace('!T','F').replace('!F','T').replace('(T)','T').replace('F&&F','F').replace('F&&T','F').replace('T&&F','F').replace('T&&T','T').replace('F||F','F').replace('F||T','T').replace('T||F','T').replace('T||T','T');
        }
        while(tempAdvancedExp != advancedExpression);

        System.debug(LoggingLevel.INFO,'advancedExpression output : ' + advancedExpression);

        if(advancedExpression.equals('T')){
            return True;
        }

        return False;
    }


    public class ExpressionWrapper{
        public List<RuleExpression> rules;
        public ExpressionWrapper(){

        }
    }


    public class RuleExpression{
        public String order;
        public String attrName;
        public String operator;
        public String attrValue;
        public String datatype;
        public String attrType;
        public String stopAt;
        public String adjType;
        public String adjValue;
        public String adjMin;
        public String adjMax;
        public String adjUnit;
        //public double adjDiff; 

        public RuleExpression(){

        }
    }

    public class ScheduleLogger{
        public boolean workOrderCreated;
        //public String scheduleId;
        public String planId;
        public String planName;
        public String strLogger;
        //public String errorMsg;
        public String processId;
        public String processName;
        public String status;
        public String ownerIdStr;

    }

    @future(callout = false)
    public static void performConditionalAdjustment(Map<Id,DateTime> woActivityCloseMap){
        PREV_Conditional_Engine_Utils utilsInstance = new PREV_Conditional_Engine_Utils();
        Set<Id> installedBaseIds = new Set<Id>();
        Map<Id, expressionWrapper> wOIdExpressionMap = new Map<Id, expressionWrapper>();
        Map<Id, Map<String,double>> coverageScheduleAdjustmentMap = new Map<Id, Map<String,double>>();
        Map<Id, Datetime> closedSchedulesIdDateMap = new Map<Id, Datetime>();

        try{
            List<SVMXC__PM_History__c> pmHistoryList = [SELECT Id, SVMXC__Installed_Product__c, SVMXC__PM_Plan__c, SVMXC__SM_PM_Schedule__c, SVMXC__SM_PM_Schedule__r.SVMXC__SM_Sequence__c, 
                                                    SVMXC__SM_PM_Schedule__r.SVMXC__SM_Expression_Internal_Value__c, SVMXC__SM_PM_Schedule__r.SVMXC__SM_PM_Coverage__c, SVMXC__Work_Order_Closed_on__c, SVMXC__Work_Order__c FROM SVMXC__PM_History__c 
                                                    WHERE SVMXC__Work_Order__c IN : woActivityCloseMap.keySet()];

            for(SVMXC__PM_History__c pmHistoryRec : pmHistoryList){
                pmHistoryRec.SVMXC__Work_Order_Closed_on__c = woActivityCloseMap.get(pmHistoryRec.SVMXC__Work_Order__c);
                closedSchedulesIdDateMap.put(pmHistoryRec.SVMXC__SM_PM_Schedule__c, pmHistoryRec.SVMXC__Work_Order_Closed_on__c);
                if(pmHistoryRec.SVMXC__SM_PM_Schedule__c != null){
                    expressionWrapper expressionJSON = utilsInstance.expressionParser(pmHistoryRec.SVMXC__Installed_Product__c, pmHistoryRec.SVMXC__SM_PM_Schedule__r.SVMXC__SM_Sequence__c, pmHistoryRec.SVMXC__SM_PM_Schedule__r.SVMXC__SM_Expression_Internal_Value__c);
                    wOIdExpressionMap.put(pmHistoryRec.SVMXC__Work_Order__c, expressionJSON);
                }
                installedBaseIds.add(pmHistoryRec.SVMXC__Installed_Product__c);
            }           

            if(!utilsInstance.technicalAttributes.isEmpty()){
                utilsInstance.getTechnicalAttributeCurrentReadings(installedBaseIds);
            }

            if(!utilsInstance.schemaAttributes.isEmpty()){
                Map<Id,SVMXC__Installed_Product__c> ibRecMap = utilsInstance.getSchemaAttributeCurrentReadings(installedBaseIds);
            }

            for(SVMXC__PM_History__c pmHistoryRec : pmHistoryList){
                expressionWrapper expressionJSON = wOIdExpressionMap.get(pmHistoryRec.SVMXC__Work_Order__c);
                
                if(!expressionJSON.rules.isEmpty()){
                    SVMXC__PM_Schedule__c scheduleInstance = new SVMXC__PM_Schedule__c(SVMXC__SM_Sequence__c = pmHistoryRec.SVMXC__SM_PM_Schedule__r.SVMXC__SM_Sequence__c, 
                                                                                           SVMXC__SM_PM_Coverage__c = pmHistoryRec.SVMXC__SM_PM_Schedule__r.SVMXC__SM_PM_Coverage__c ) ;
                    //scheduleInstance.SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c = pmHistoryRec.SVMXC__Installed_Product__c;
                    utilsInstance.checkAdjustment(expressionJSON.rules, coverageScheduleAdjustmentMap, scheduleInstance, pmHistoryRec.SVMXC__Work_Order_Closed_on__c, pmHistoryRec.SVMXC__Installed_Product__c);
                }

            }
            
            List<SVMXC__PM_Schedule__c> updateScheduleList = utilsInstance.deleteAndRecreateSchedules(coverageScheduleAdjustmentMap, closedSchedulesIdDateMap, new List<SVMXC__PM_Schedule__c>());      
            System.debug(LoggingLevel.DEBUG, 'updateScheduleList :' + updateScheduleList);

            if(!updateScheduleList.isEmpty()){
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(updateScheduleList[0], COMM_SecurityUtils.Access.Updateable)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                update updateScheduleList;
            }

            if(!pmHistoryList.isEmpty()){
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(pmHistoryList[0], COMM_SecurityUtils.Access.Updateable)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                update pmHistoryList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Future Handle Exception :  \n' +  ex.getTypeName() +  '\n' + ex.getMessage() + '\n ' + ex.getStackTraceString());
        }

    }

    void checkAdjustment(List<RuleExpression> conditionalRules, Map<Id, Map<String,double>> coverageScheduleAdjustmentMap, SVMXC__PM_Schedule__c scheduleInstance, DateTime activityDate, Id ibId){
        for(RuleExpression ruleExpRecord : conditionalRules){
        
            if(ruleExpRecord.attrName != null && ruleExpRecord.adjType != null){
                
                String uniqueIbAttributeKeyForTarget = ibId + ruleExpRecord.attrName.trim() + scheduleInstance.SVMXC__SM_Sequence__c + ruleExpRecord.order.trim();
                String uniqueIbAttributeKey = ibId + ruleExpRecord.attrName.trim();

                String actualReading,closedReading;
                if(targetAttributeReadings.containsKey(uniqueIbAttributeKeyForTarget)){
                    actualReading = targetAttributeReadings.get(uniqueIbAttributeKeyForTarget);
                }

                
                if(currentAttributeReadings.containsKey(uniqueIbAttributeKey)){
                    closedReading = currentAttributeReadings.get(uniqueIbAttributeKey);
                }else if(ruleExpRecord.attrType.equalsIgnoreCase(ATTRIBUTE_TYPE_STRING_LITERAL)){
                    if(ruleExpRecord.attrName.trim().equalsIgnoreCase('Today')){
                        DateTime dt = activityDate;
                        String utcDt = dt.format('yyyy-MM-dd', 'UTC'); 
                        closedReading = utcDt;
                    }
                }

                if(actualReading != null && closedReading != null){
                    System.debug(LoggingLevel.INFO, 'actualReading :' +  actualReading  + ' closedReading ' + closedReading );

                    double diff = toBeAdjusted(actualReading, closedReading, ruleExpRecord);

                    System.debug(LoggingLevel.INFO, 'Adjustment Difference :' +  diff);
                    if(diff != null){
                        //ruleExpRecord.adjDiff = diff;
                        Map<String,double> tempMap = new Map<String,double>();
                        if(coverageScheduleAdjustmentMap.containsKey(scheduleInstance.SVMXC__SM_PM_Coverage__c)){
                            tempMap = coverageScheduleAdjustmentMap.get(scheduleInstance.SVMXC__SM_PM_Coverage__c);
                        }
                        String ruleOrder = ruleExpRecord.order.trim();
                        tempMap.put(ruleOrder, diff);
                        coverageScheduleAdjustmentMap.put(scheduleInstance.SVMXC__SM_PM_Coverage__c,tempMap);
                    }
                }

            }
        }       

    }

    List<SVMXC__PM_Schedule__c> deleteAndRecreateSchedules(Map<Id, Map<String,Double>> coverageScheduleAdjustmentMap, Map<Id, Datetime> closedSchedulesIdDateMap, List<SVMXC__PM_Schedule__c> rescheduleList){
        Set<Id> coverageEndIds = new Set<Id>();
        List<SVMXC__PM_Schedule__c> scheduleUpdateList = new List<SVMXC__PM_Schedule__c>();
        //List<SVMXC__PM_Schedule__c> deleteScheduleList = new List<SVMXC__PM_Schedule__c>();

        if(rescheduleList.isEmpty()){
            rescheduleList = [SELECT Id, SVMXC__SM_Expression_Internal_Value__c,SVMXC__SM_PM_Coverage__c, SVMXC__SM_PM_Coverage__r.SVMXC__SM_Advanced_Expression__c, SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c,SVMXC__SM_Status__c,SVMXC__PM_Plan__c, SVMXC__PM_Plan__r.SVMXC__SM_Advanced_Expression__c FROM SVMXC__PM_Schedule__c WHERE SVMXC__SM_Status__c IN ('', 'Work Order Created') AND 
                                                         SVMXC__SM_PM_Coverage__c IN : coverageScheduleAdjustmentMap.keySet() Order by SVMXC__SM_Sequence__c ASC];
        }
        
        for(SVMXC__PM_Schedule__c rescheduleRecord : rescheduleList){
            if(closedSchedulesIdDateMap.containsKey(rescheduleRecord.Id)){
                rescheduleRecord.SVMXC__SM_Status__c = STATUS_WO_DONE;
                
                expressionWrapper expressionJSON = (expressionWrapper) JSON.deserialize(rescheduleRecord.SVMXC__SM_Expression_Internal_Value__c,expressionWrapper.class);
                for(RuleExpression ruleExpRecord : expressionJSON.rules){
                    
                    String uniqueIbAttributeKey = rescheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__Product_Name__c + ruleExpRecord.attrName.trim();
                    
                    if(currentAttributeReadings.containsKey(uniqueIbAttributeKey)){
                        ruleExpRecord.attrValue = currentAttributeReadings.get(uniqueIbAttributeKey);
                    }else if(ruleExpRecord.attrType.equalsIgnoreCase(ATTRIBUTE_TYPE_STRING_LITERAL)){
                        if(ruleExpRecord.attrName.trim().equalsIgnoreCase('Today')){
                            DateTime dt = closedSchedulesIdDateMap.get(rescheduleRecord.Id);
                            String utcDt = dt.format('yyyy-MM-dd', 'UTC'); 
                            ruleExpRecord.attrValue = utcDt;
                        }
                    }                   
                }

                Object serializedRule = JSON.serialize(expressionJSON);
                rescheduleRecord.SVMXC__SM_Expression_Actual_Output_Value__c = String.valueOf(serializedRule);
                rescheduleRecord.SVMXC__SM_Advanced_Expression__c = (rescheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__SM_Advanced_Expression__c != null) ? rescheduleRecord.SVMXC__SM_PM_Coverage__r.SVMXC__SM_Advanced_Expression__c : rescheduleRecord.SVMXC__PM_Plan__r.SVMXC__SM_Advanced_Expression__c;
                scheduleUpdateList.add(rescheduleRecord);
            }

            if(!coverageEndIds.contains(rescheduleRecord.SVMXC__SM_PM_Coverage__c)){
                System.debug(LoggingLevel.DEBUG, 'coverageScheduleAdjustmentMap : ' +  coverageScheduleAdjustmentMap.keySet());
                if(rescheduleRecord.SVMXC__SM_Status__c == null && coverageScheduleAdjustmentMap.containsKey(rescheduleRecord.SVMXC__SM_PM_Coverage__c)){
                    Map<String,Double> conditionAdjustmentMap = coverageScheduleAdjustmentMap.get(rescheduleRecord.SVMXC__SM_PM_Coverage__c);
                    
                    expressionWrapper expressionJSON = (expressionWrapper) JSON.deserialize(rescheduleRecord.SVMXC__SM_Expression_Internal_Value__c,expressionWrapper.class);

                    if(expressionJSON != null && expressionJSON.rules != null){
                       
                        for(RuleExpression ruleExpRecord : expressionJSON.rules){
                            String ruleOrder = ruleExpRecord.order.trim();
                            if(conditionAdjustmentMap.containsKey(ruleOrder)){
                                double diff = conditionAdjustmentMap.get(ruleOrder);
                                ruleExpRecord.attrValue = doAdjust(ruleExpRecord, diff);
                                
                                if(ruleExpRecord.attrValue == 'end'){
                                    coverageEndIds.add(rescheduleRecord.SVMXC__SM_PM_Coverage__c);
                                    break;

                                }
                            }
                        }

                        if(!coverageEndIds.contains(rescheduleRecord.SVMXC__SM_PM_Coverage__c)){
                            Object serializedRule = JSON.serialize(expressionJSON);
                            rescheduleRecord.SVMXC__SM_Expression_Internal_Value__c = String.valueOf(serializedRule);
                            System.debug(LoggingLevel.DEBUG, ' Expression Value ' + rescheduleRecord.SVMXC__SM_Expression_Internal_Value__c);
                            scheduleUpdateList.add(rescheduleRecord);
                        }else{
                            rescheduleRecord.SVMXC__SM_Status__c = STATUS_WO_EXCEEDED;
                            scheduleUpdateList.add(rescheduleRecord);
                        }
                    }
                }
            }else{
                rescheduleRecord.SVMXC__SM_Status__c = STATUS_WO_EXCEEDED;
                scheduleUpdateList.add(rescheduleRecord);
            }
        }

        System.debug(LoggingLevel.DEBUG, 'rescheduleList :' + scheduleUpdateList);
        return scheduleUpdateList;
        
    }

    String doAdjust(ruleExpression ruleExpRecord, double diff){
        if(ruleExpRecord.datatype.equalsIgnoreCase('Number')){
            double adjustVal;
            if(ruleExpRecord.operator == 'EYI'){
                adjustVal = Double.valueOf(ruleExpRecord.attrValue) + diff;
                if(adjustVal <= Double.valueOf(ruleExpRecord.stopAt)){
                    return String.valueOf(adjustVal);
                }               
            }else if(ruleExpRecord.operator == 'EYD'){
                adjustVal = Double.valueOf(ruleExpRecord.attrValue) - diff;
                if(adjustVal >= Double.valueOf(ruleExpRecord.stopAt)){
                    return String.valueOf(adjustVal);
                }   
            }
        }else if(ruleExpRecord.datatype.equalsIgnoreCase('Date')){
            date adjustedDate;
            if(ruleExpRecord.operator == 'EYI'){
                adjustedDate = Date.valueOf(ruleExpRecord.attrValue).addDays(integer.valueOf(diff));
            }

            if(adjustedDate <= Date.valueOf(ruleExpRecord.stopAt)){
                datetime adjustedDateTime = Datetime.newInstance(adjustedDate.year(), adjustedDate.month(), adjustedDate.day());
                return adjustedDateTime.format('yyyy-MM-dd', 'UTC');
            }   
        }
        return 'end';
    }

    double toBeAdjusted(String actualReading, String closedReading, PREV_Conditional_Engine_Utils.RuleExpression ruleExpRecord){
        if(ruleExpRecord.adjType != null){
            double diff;
            if(ruleExpRecord.datatype.equalsIgnoreCase('Number')){
                
                if(ruleExpRecord.operator == 'EYI'){
                    diff = Double.valueOf(closedReading) - Double.valueOf(actualReading);
                    if(diff > 0){
                        if(diff > double.valueOf(ruleExpRecord.adjMin) && diff <= double.valueOf(ruleExpRecord.adjMax)){
                            if(ruleExpRecord.adjType.equalsIgnoreCase('Actual')){
                                return diff;
                            }else if(ruleExpRecord.adjType.equalsIgnoreCase('Fixed')){
                                return double.valueof(ruleExpRecord.adjValue);
                            }
                        }else if(diff > double.valueOf(ruleExpRecord.adjMax)){
                            return double.valueof(ruleExpRecord.adjMax);
                        }
                    }
                }else if(ruleExpRecord.operator == 'EYD'){
                    diff = Double.valueOf(actualReading) - Double.valueOf(closedReading);
                    if(diff > 0){
                        if(diff > double.valueOf(ruleExpRecord.adjMin) && diff <= double.valueOf(ruleExpRecord.adjMax)){
                            if(ruleExpRecord.adjType.equalsIgnoreCase('Actual')){
                                return diff;
                            }else if(ruleExpRecord.adjType.equalsIgnoreCase('Fixed')){
                                return double.valueof(ruleExpRecord.adjValue);
                            }
                        }else if(diff > double.valueOf(ruleExpRecord.adjMax)){
                            return double.valueof(ruleExpRecord.adjMax);
                        }
                    }
                }
            }else if(ruleExpRecord.datatype.equalsIgnoreCase('Date')){
                if(Date.valueOf(closedReading) >= Date.valueOf(actualReading)){
                    diff = Date.valueOf(actualReading).daysBetween(Date.valueOf(closedReading));
                    System.debug(LoggingLevel.DEBUG, 'Difference :' + diff);
                    if(ruleExpRecord.operator == 'EYI'){
                        if(diff > double.valueOf(ruleExpRecord.adjMin) && diff <= double.valueOf(ruleExpRecord.adjMax)){
                            if(ruleExpRecord.adjType.equalsIgnoreCase('Actual')){
                                return diff;
                            }else if(ruleExpRecord.adjType.equalsIgnoreCase('Fixed')){
                                return double.valueof(ruleExpRecord.adjValue);
                            }
                        }else if(diff > double.valueOf(ruleExpRecord.adjMax)){
                            return double.valueof(ruleExpRecord.adjMax);
                        }
                    }   
                }           
            }
        }

        return null;
    }

    expressionWrapper expressionParser(Id ibRecordId, Decimal sequence, string expressionObject){
        expressionWrapper expressionJSON = (expressionWrapper) JSON.deserialize(expressionObject,expressionWrapper.class);

        if(expressionJSON != null && expressionJSON.rules != null){
            
            for(ruleExpression ruleExpRecord : expressionJSON.rules){
                
                if(ruleExpRecord.attrName != null){
                    String targetValue = (ruleExpRecord.attrValue != null) ? ruleExpRecord.attrValue : '';
                    String uniqueIbAttributeKey = ibRecordId + ruleExpRecord.attrName.trim() + sequence + ruleExpRecord.order.trim();
                    targetAttributeReadings.put(uniqueIbAttributeKey, targetValue);

                    if(ruleExpRecord.attrType.equalsIgnoreCase(ATTRIBUTE_TYPE_TECHNICAL)){
                        technicalAttributes.add(ruleExpRecord.attrName.trim());
                    }else if(ruleExpRecord.attrType.equalsIgnoreCase(ATTRIBUTE_TYPE_SCHEMA)){
                        schemaAttributes.add(ruleExpRecord.attrName.trim());    
                    }   
                }
            }
        }   

        return expressionJSON;
    }

    void getTechnicalAttributeCurrentReadings(Set<Id> installedBaseIds){
        
        //Querying all the technical attributes and creating a map with the current readings
        for(SVMXC__SM_IB_Technical_Attributes__c technicalAttrRec : [SELECT Id, SVMXC__SM_Attr_Name__c, SVMXC__SM_Attr_Value__c , SVMXC__SM_IBAttr_ExtId__c, SVMXC__SM_Installed_Product_id__c FROM 
                                                                       SVMXC__SM_IB_Technical_Attributes__c WHERE SVMXC__SM_IsActive__c = true AND SVMXC__SM_Installed_Product_id__c IN : installedBaseIds 
                                                                       AND SVMXC__SM_Attr_Name__c IN : technicalAttributes]){
            
            if(technicalAttrRec.SVMXC__SM_Installed_Product_id__c != null && technicalAttrRec.SVMXC__SM_Attr_Name__c != null){
                String uniqueIbAttributeKey = technicalAttrRec.SVMXC__SM_Installed_Product_id__c + technicalAttrRec.SVMXC__SM_Attr_Name__c.trim() ; 
                
                if(technicalAttrRec.SVMXC__SM_Attr_Value__c != null){
                    currentAttributeReadings.put(uniqueIbAttributeKey,technicalAttrRec.SVMXC__SM_Attr_Value__c);
                }else{
                    currentAttributeReadings.put(uniqueIbAttributeKey,'');
                }
            }
        }

    }

    String getQueryFieldString(map<String, Schema.SObjectField> mapFieldDesc){
        String queryFields='';
        for (String field : mapFieldDesc.keySet()) {
            if (queryFields.length()>0) {
                queryFields += ',';
            }
            queryFields += field;
        } 
        return queryFields;  
    }

    Map<Id,SVMXC__Installed_Product__c> getSchemaAttributeCurrentReadings(Set<Id> installedBaseIds){
        /*
            Querying all physical attributes i.e Installed products with all the fields required for mapping.
        */
        Schema.DescribeSobjectResult objResult = getFieldDescribe('SVMXC__Installed_Product__c');
        map<String, Schema.SObjectField> mapFieldDesc = objResult.fields.getMap();

        String queryFields = getQueryFieldString(mapFieldDesc);
            

        String queryString = 'SELECT ' + queryFields + ' , SVMXC__Preferred_Technician__r.SVMXC__Salesforce_User__c, SVMXC__Preferred_Technician__r.SVMXC__Salesforce_User__r.IsActive FROM SVMXC__Installed_Product__c WHERE ID IN: installedBaseIds';

        List<SVMXC__Installed_Product__c>  installedProductsList = Database.query(queryString);

        Map<Id,SVMXC__Installed_Product__c> ibRecMap = new Map<Id,SVMXC__Installed_Product__c>();

        System.debug(LoggingLevel.DEBUG, 'Installed Products Queried' + installedProductsList.size());

        for(SVMXC__Installed_Product__c iBRec : installedProductsList){
            String currentValue,uniqueIbAttributeKey;
            ibRecMap.put(iBRec.Id, iBRec);
            
            if(!schemaAttributes.isEmpty()){    
            
                for(String ibField : schemaAttributes){
                    currentValue = '';
                    if(iBRec.get(ibField) != null){
                        currentValue = String.valueOf(iBRec.get(ibField)); 
                    }
                    uniqueIbAttributeKey = iBRec.Id + ibField;
                    currentAttributeReadings.put(uniqueIbAttributeKey, currentValue);
                }
            }   
        }
        return ibRecMap;
    }

    
}