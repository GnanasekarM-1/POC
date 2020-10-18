/**
@ Name WSCH_TriggerHanlder
@ Author Anantha Kumar
@ Description Define future call to schedule workorders. Invokes the SP API call based on the type of change in work order
 */
public with sharing class WSCH_TriggerHandler {
    
    public class SVMXException extends Exception {}
    public static boolean rulesExecuted = false; 
    public static String strOldWO = 'old workorder values';
    public static String strBookJobCustomFields;
    public static String strUpdateJobCustomFields;
    
    public static String strScheToken;
    
    public static Map<String,String> mapWoSchToken;
    public static boolean isForceFixSchedDate;
    public static Boolean isSmaxQSettingEnabled = false;
    public static Map<String, Schema.SObjectField> mapOfFields;
    public static Map<String, Schema.SObjectType> gblDesc;
    public static Set<String> setStrCustomFields = new Set<String>();
    public static map<string, Map<String, String>> lstDCEventMgmtSettings = new map<string, Map<String, String>>();
    
    public static boolean isQTLResourcePrefCalculated = false;
    
    static {
        /*WSCH_AuditLogger.debug('WSCH_TriggerHandler::Inside static block');
        system.debug('WSCH_TriggerHandler::Inside static block');
        WSCH_AuditLogger.debug('WSCH_TriggerHandler:: SVMX_Constants.AllsvmxSettingList - : ' +  SVMX_Constants.AllsvmxSettingList);
        strBookJobCustomFields = WSCH_CommonUtils.getSettingValue('DCON004','SET009');
        strUpdateJobCustomFields = WSCH_CommonUtils.getSettingValue('DCON004','SET008');
        isSmaxQSettingEnabled = getSmaxQSetting();
        mapOfFields = new Map<String, Schema.SObjectField> ();
        gblDesc = Schema.getGlobalDescribe();
        mapOfFields = gblDesc.get('SVMXC__Service_Order__c').getDescribe().fields.getMap();
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::mapOfFields - ' + mapOfFields);
        setStrCustomFields.addAll(fetchSetJobFields());
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::mapOfFields - ' + setStrCustomFields);
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::strBookJobCustomFields - ' + strBookJobCustomFields);
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::strUpdateJobCustomFields - ' + strUpdateJobCustomFields);
        system.debug('WSCH_TriggerHandler::strBookJobCustomFields - ' + strBookJobCustomFields);
        system.debug('WSCH_TriggerHandler::strUpdateJobCustomFields - ' + strUpdateJobCustomFields);*/
    }

    public static void doQualifyWorkorder(List<SVMXC__Service_Order__c> workorderList){
        
        try{
            WSCH_AuditLogger.debug('Start of WSCH_TriggerHandler::doQualifyWorkorder():No of Queries used in this trigger code so far: ' + Limits.getQueries());
            
            //get the qualified workorder ids.
            if(!WSCH_CommonUtils.isOptimizerEnabled()) {
                return;
            }
            List<String> qualifiedWOIds = getQualifiedWOIds(workorderList);
            mapWoSchToken = new Map<String,String>();

            if(qualifiedWOIds.size() > 0){
                //Call the Abstraction Service to Schedule the WorkOrders.
                if(System.isBatch() || System.isFuture()) {
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQualifyWorkorder()::Source is a FutureCall/Batch, So mark the workOrder for Batch execution :'+qualifiedWOIds);
                    updateWorkOrders(qualifiedWOIds, WSCH_Constants.STATUS_OPT_BATCH, 'CHANGE_CREATE_WO');
                    WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.WO_BATCH_CLASS_NAME, WSCH_Constants.BATCH_APEX_START_TIME);
                } else {
                    updateWorkOrders(qualifiedWOIds, WSCH_Constants.STATUS_OPT_PENDING, 'CHANGE_CREATE_WO');
                    WSCH_AuditLogger.debug('Before calling manageWorkOrders API (future call)...');
                    WSCH_AuditLogger.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
                    System.debug(logginglevel.DEBUG,'BEFORE manageWorkOrders: CPU TIME: '+ Datetime.now() + 'BEFORE: DML: ' + Limits.getLimitDMLStatements() + 'BEFORE: SOQL: ' + Limits.getLimitQueries());
                    if((isSmaxQSettingEnabled != null) &&(!isSmaxQSettingEnabled)){
                        manageWorkOrders(qualifiedWOIds);
                    }
                    
                    for(String strQualWo: qualifiedWOIds){
                        mapWoSchToken.put(strQualWo, 'CHANGE_CREATE_WO');
                    }
                    System.debug(logginglevel.DEBUG,'AFTER manageWorkOrders: CPU TIME: '+ Datetime.now() + 'AFTER: DML: ' + Limits.getLimitDMLStatements() + 'AFTER: SOQL: ' + Limits.getLimitQueries());
                }
                if(!mapWoSchToken.isEmpty()){
                    createOptTrans(mapWoSchToken);                  
                }
                WSCH_AuditLogger.finish();
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_TriggerHandler:doQualifyWorkorder() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        System.debug('End of WSCH_TriggerHandler::doQualifyWorkorder():No of Queries used in this trigger code so far: ' + Limits.getQueries());
    }

    /** Workorder Qualification logic implemented in this method.*/
    public static List<String> getQualifiedWOIds(List<SVMXC__Service_Order__c> workorderList){

        List<String> qualifiedWOIds = new List<String>();
        Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        try{
            /* Get the list of all valid dispatch processes ids for Linx for ServicePower */
            //mapSVMXProcess.putAll([SELECT Id from SVMXC__ServiceMax_Processes__c where (RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Process_Status__c = 'Complete'
            //      and SVMXC__Dispatch_Method__c ='Linx for ServicePower'
            //      and (SVMXC__End_Date__c >=: system.now().dateGMT() or SVMXC__End_Date__c=null)) or RecordType.Name = 'SVMX Rule' order by SVMXC__Sequence__c]);
            mapSVMXProcess = WSCH_CommonUtils.getContinuousDP();
            for(SVMXC__Service_Order__c currWorkOrder : workOrderList){
                // added below code to avoid API call if the work worder is scheduled for dependency group booking 
                if(currWorkOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c == true){
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQualifyWorkorder()::Removing Work Order from the List as the WO is scheduled to be part of dependency group: '+currWorkOrder);              
                    continue;
                }
                if(currWorkOrder != null && currWorkOrder.SVMXC__Locked_By_DC__c != true && (currWorkOrder.SVMXC__Dispatch_Process__c != NULL || currWorkOrder.SVMXC__OptiMax_Error_Occurred__c != true)){
                        if(mapSVMXProcess.ContainsKey(currWorkOrder.SVMXC__Dispatch_Process__c)){
                           qualifiedWOIds.add(currWorkOrder.Id);
                       }
                    }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_TriggerHandler:getQualifiedWOIds() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return qualifiedWOIds;
    }

    public static void updateWorkOrders(List<String> workOrderIds, String status, String changeType) {

        List<SVMXC__Service_Order__c> workOrderList = WSCH_CommonUtils.fetchWorkOrders(workOrderIds);
        List<SVMXC__Service_Order__c> lstUpdateWos = new   List<SVMXC__Service_Order__c>();
        for(SVMXC__Service_Order__c workOrder: workOrderList) {
            workOrder.SVMXC__OptiMax_Status__c = status;
            workOrder.SVMXC__Scheduling_Change_Token__c = changeType;
            updateWoOptStatus(workOrder);
        }   
        WSCH_CommonUtils.getWorkorderFields();
        if((WSCH_CommonUtils.strSetOfUpdateableFields != null) && (!WSCH_CommonUtils.strSetOfUpdateableFields.isEmpty())){
            lstUpdateWos.addAll(workOrderList);
            workOrderList = new List<SVMXC__Service_Order__c>();
            workOrderList.addAll(WSCH_CommonUtils.getMapOfWorkOrders(WSCH_CommonUtils.strSetOfUpdateableFields, lstUpdateWos).values());
        }else{
            WSCH_AuditLogger.debug('WSCH_TriggerHandler:workOrderList:strSetOfUpdateableFields: ' + WSCH_CommonUtils.strSetOfUpdateableFields);
        }
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
        
        if(workOrderList != null && workOrderList.size() > 0) {
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(workOrderList, COMM_SecurityUtils.Access.Updateable)){    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update workOrderList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        /*List<SVMXC__Service_Order__c> workOrderList = WSCH_CommonUtils.fetchWorkOrders(workOrderIds);
        for(SVMXC__Service_Order__c workOrder: workOrderList) {
            workOrder.SVMXC__OptiMax_Status__c = status;
            workOrder.SVMXC__Scheduling_Change_Token__c = changeType;
        }
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        update workOrderList;*/
    }

    @future(callout=true)
    public static void manageWorkOrders(List<String> workOrderIdList){
        /*
            Calling Abstract services method to schedule the work orders.
         */
         Map<String, Map<String, Object>> oldWOIdFieldValuesMap = new Map<String, Map<String, Object>>();
         List<String> workOrderIds = new List<String>();
         String logContext = '';
         WSCH_AuditLogger.debug('Start of Future call: No of Queries used in this transaction so far: ' + Limits.getQueries());
         WSCH_AuditLogger.debug('Start of Future call :heap size - ' + Limits.getHeapSize());
         WSCH_AuditLogger.debug('WSCH_TriggerHandler:manageWorkOrders(): workOrderIdList ' + workOrderIdList);
         try {
            for(String eachWODetail : workOrderIdList) {
                if(eachWODetail.contains(':')){
                    Map<String, Object> oldWODetail = (Map<String, Object>)JSON.Deserializeuntyped(eachWODetail);
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler:manageWorkOrders(): after deserialization JSON, oldWODetail ' + oldWODetail);
                    oldWOIdFieldValuesMap.put(String.valueOf(oldWODetail.get('WOId')),oldWODetail);
                    workOrderIds.add(String.valueOf(oldWODetail.get('WOId')));
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler:manageWorkOrders(): workOrderIds ' + workOrderIds);
                }
                else{
                    workOrderIds.add(eachWODetail);
                }
            }
         } catch(Exception ex) {
            WSCH_AuditLogger.error('WSCH_TriggerHandler:manageWorkOrders(): workOrderIdList does not contain JSON ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            //workOrderIds = workOrderIdList;
         }
         
         
        try{
            List<SVMXC__Service_Order__c> workOrderList = WSCH_CommonUtils.fetchWorkOrders(workOrderIds);
            WSCH_AuditLogger.debug('WSCH_TriggerHandler:manageWorkOrders(): workOrderList ' + workOrderList);
            List<SVMXC__Service_Order__c> manageDependencyWorkOrderList = new List<SVMXC__Service_Order__c>();
            List<SVMXC__Service_Order__c> manageWorkOrderList = new List<SVMXC__Service_Order__c>();
            WSCH_AuditLogger.debug('WSCH_TriggerHandler:manageWorkOrders(): oldWOIdFieldValuesMap ' + oldWOIdFieldValuesMap);
            //compare the OldWO's from the map with the above new list of WO's for custom fields change and get the latestWOList.
            if(oldWOIdFieldValuesMap != null && oldWOIdFieldValuesMap.size() > 0) {
                WSCH_AuditLogger.debug('WSCH_TriggerHandler:manageWorkOrders(): oldWOIdFieldValuesMap is not null');
                //workOrderList = getChangedWOList(manageWorkOrderList, oldWOIdFieldValuesMap);
                workOrderList = getChangedWOList(workOrderList, oldWOIdFieldValuesMap);
            }
            WSCH_AuditLogger.debug('WSCH_TriggerHandler:manageWorkOrders():workOrderList'+workOrderList);
            //updating the audit logger object's context field with the current WO name
            /*for(SVMXC__Service_Order__c eachWO : manageWorkOrderList) {
                if((WSCH_AuditLogger.strLogContext.length() + 11) < 255) {
                    WSCH_AuditLogger.strLogContext = WSCH_AuditLogger.strLogContext + eachWO.Name + ', ';
                }
            }*/
            for(SVMXC__Service_Order__c eachWO : workOrderList) {
                if((logContext.length() + 11) < 255) {
                    logContext = logContext + eachWO.Name + ', ';
                    WSCH_AuditLogger.setLogContext(logContext);
                }
                WSCH_AuditLogger.debug('eachWO.SVMXC__OptiMax_Error_Text__c-->'+eachWO.SVMXC__OptiMax_Error_Text__c);
                /*For book dependency group API call
                */                
                if(eachWO.SVMXC__Scheduling_Change_Token__c == 'CREATE_DEPENDENCY_WO' || eachWO.SVMXC__Scheduling_Change_Token__c == 'CHANGE_DEPENDENCY_WO'){
                    manageDependencyWorkOrderList.add(eachWO);
                }
                else{
                    manageWorkOrderList.add(eachWO);
                }
            }
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::manageWorkOrders:: WOs qualified for dependency Group:'+manageDependencyWorkOrderList);
            if(manageDependencyWorkOrderList != null){
                Set<Id> dependencyManagementId = new Set<Id>();
                //List<Id> groupDependencyId = new List<Id>();
                for(SVMXC__Service_Order__c dependencyWO: manageDependencyWorkOrderList){
                    dependencyManagementId.add(dependencyWO.SVMXC__Dependency_Group__c);
                }
                
                if(dependencyManagementId.size() > 0){
                    for(Id depGroupId : dependencyManagementId){
                        List<SVMXC__Service_Order_Dependency__c> dependencyGroupList = new List<SVMXC__Service_Order_Dependency__c>();
                        dependencyGroupList = WSCH_CommonUtils.fetchGroupDependency(depGroupId);
                        WSCH_OptimizedSchedulingService.manageDependencyGroup(depGroupId, dependencyGroupList);
                    }
                }
            }
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::manageWorkOrders:: WOs qualified for normal UpdateJob call:'+manageWorkOrderList);            
            if(manageWorkOrderList.size() > 0){
                WSCH_OptimizedSchedulingService.manageWorkOrders(manageWorkOrderList);
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_TriggerHandler:manageWorkOrders() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    /** Method to identify SP API and Optimize based on the work order field changes **/
    public static void identifyAPIAndOptimize(List<SVMXC__Service_Order__c> newWoList,List<SVMXC__Service_Order__c> oldWoList) {
        
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::identifyAPIAndOptimize():Entering into update qualification logic..');
        System.debug('Start of WSCH_TriggerHandler::identifyAPIAndOptimize():No of Queries used in this trigger code so far: ' + Limits.getQueries());
        //check the optimization enabled and optimizer is ServicePower
        //commented below line. This check is added in the WO trigger itself before making this method call
        if(!WSCH_CommonUtils.isOptimizerEnabled()) {
            return;
        }
        //get the type of source call
        boolean isFutureContext = System.isBatch() || System.isFuture();
        boolean startBatch = false;
        mapWoSchToken = new Map<String,String>();
        //Map<String, Object> woFieldValuesMap = new Map<String, Object>();
        List<String> lstOfCustomFields = getCustomFieldsFromSettings();
        List<String> serializedWOInfo = new List<String>();
        String logContext = '';
        
        Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap = WSCH_CommonUtils.getContinuousDP();
        Set<SVMXC__Service_Order__c> updatedWoSet = new Set<SVMXC__Service_Order__c>();
        Set<String> linxWOsSet = new Set<String>();
        
        for(Integer i = 0; i < newWoList.size(); i++){
            
            SVMXC__Service_Order__c newWO = newWoList[i];
            SVMXC__Service_Order__c oldWO = oldWoList[i];
            
           //Checking if this workorder is qualifying for Book Job,Book Appointment and Dependency Job.
            if(newWO.SVMXC__Schedule_As_A_Dependent_Work_Order__c && newWO.SVMXC__Dependency_Group__c == null){
                continue;
            }
            //if the work order is NOT a BookJob,BookAppointment, DependencyGroup work order, then continue to next work order.
            if (!(isBookJobWO(newWO, svmxProcessMap) || isAppointmentWO(newWO) || isForceScheduleBookedWO(oldWO) || newWO.SVMXC__Dependency_Group__c != null)) {
                continue;
            }
            //adding Linx qualified workorder to this set
            linxWOsSet.add(newWO.id); 
             
            //updating the audit logger object's context field with the current WO name
            if((logContext.length() + 11) < 255) {
                logContext = logContext + oldWO.Name + ', ';
                WSCH_AuditLogger.setLogContext(logContext);
            }
            
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::identifyAPIAndOptimize()::Old WorkOrder Schedule :'+oldWO.SVMXC__Scheduled_Date_Time__c+'| OldWO.Duration :'+oldWO.SVMXC__Service_Duration__c+'| OldWO.LockedByDC :'+oldWO.SVMXC__Locked_By_DC__c+'| OldWO.Technician :'+oldWO.SVMXC__Group_Member__c+'| OldWO.Dispatch Status :'+oldWO.SVMXC__Dispatch_Status__c+'| OldWO.FirstAssigned :'+newWO.SVMXC__First_Assigned_DateTime__c+'| OldWO.PreviousScheduled :'+newWO.SVMXC__Previous_Scheduled_Date_Time__c);
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::identifyAPIAndOptimize()::New WorkOrder Schedule :'+newWO.SVMXC__Scheduled_Date_Time__c+'| NewWO.Duration :'+newWO.SVMXC__Service_Duration__c+'| NewWO.LockedByDC :'+newWO.SVMXC__Locked_By_DC__c+'| NewWO.Technician :'+newWO.SVMXC__Group_Member__c+'| NewWO.Dispatch Status :'+newWO.SVMXC__Dispatch_Status__c+'| NewWO.FirstAssigned :'+newWO.SVMXC__First_Assigned_DateTime__c+'| NewWO.PreviousScheduled :'+newWO.SVMXC__Previous_Scheduled_Date_Time__c+'| UnAssignDC flag :'+WSCH_OptimizedSchedulingService.isUnAssignDC);
            
            Map<String, Object> woFieldValuesMap = new Map<String, Object>();           
            if(lstOfCustomFields != null && lstOfCustomFields.size() > 0) {
                WSCH_AuditLogger.debug('WSCH_TriggerHandler::identifyAPIAndOptimize():lstOfCustomFields-  ' + lstOfCustomFields);
                //populate the woFieldValuesMap with WO custom fields and its values
                for(Integer j=0; j<lstOfCustomFields.size(); j++) {
                    String strEachCustomField = (lstOfCustomFields.get(j)).trim();
                    woFieldValuesMap.put(lstOfCustomFields.get(j), oldWO.get(strEachCustomField));
                }
                //finally add the following fields also to the map
                woFieldValuesMap.put('SVMXC__OptiMax_Status__c', oldWO.SVMXC__OptiMax_Status__c);
                woFieldValuesMap.put('SVMXC__Scheduling_Change_Token__c', oldWO.SVMXC__Scheduling_Change_Token__c);
            }

            woFieldValuesMap.put('WOId', oldWO.Id);
            
            //Check if the order status is canceled. If canceled , no update calls made to SP.
            if('Canceled'.equalsIgnoreCase(oldWO.SVMXC__Order_Status__c)) {
                continue;
            }

            //Check the job qualify for force fixing.
            System.debug('inside identifyAPIAndOptimize() -->');
            isForceFixSchedDate = false;
            if(isFixWO(newWO,oldWO)) {
                WSCH_AuditLogger.debug('WSCH_TriggerHandler::identifyAPIAndOptimize()::Qualify for ForceFix');
                newWO.SVMXC__Scheduling_Change_Token__c = getChangeToken(oldWO.SVMXC__OptiMax_Status__c,oldWO.SVMXC__Scheduling_Change_Token__c,'CHANGE_JOB_FIXED');
                woFieldValuesMap.put('PROCESS_FURTHER', true);
                String strForceSchedToken = '';
                if(isForceFixSchedDate){
                    strForceSchedToken = String.valueOf(newWO.SVMXC__Scheduling_Change_Token__c) +',' + String.valueOf(newWO.SVMXC__Scheduled_Date_Time__c);
                    //strForceSchedToken = String.valueOf(newWO.SVMXC__Scheduling_Change_Token__c) +',' + String.valueOf(WSCH_DateUtils.doTZConversion(newWO.SVMXC__Scheduled_Date_Time__c,UserInfo.getTimeZone().getID(),'GMT'));
                    System.debug('###DATE: ' + newWO.SVMXC__Scheduled_Date_Time__c + ' : ' +String.valueOf(WSCH_DateUtils.doTZConversion(newWO.SVMXC__Scheduled_Date_Time__c,UserInfo.getTimeZone().getID(),'GMT')));
                }else{
                    strForceSchedToken = String.valueOf(newWO.SVMXC__Scheduling_Change_Token__c);
                }
                mapWoSchToken.put(newWO.id, strForceSchedToken);
                updatedWoSet.add(newWO);
                newWO.SVMXC__OptiMax_Status__c = isFutureContext? WSCH_Constants.STATUS_OPT_BATCH : WSCH_Constants.STATUS_OPT_PENDING;
                updateWoOptStatus(newWO);
                newWO.SVMXC__Scheduling_Retry_Count__c = 0;
                startBatch = true;
            } else {
                if(WSCH_DependencyTriggerHandler.getDependencySetting() == false && newWoList[i].SVMXC__Dependency_Group__c != null){
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::identifyAPIAndOptimize: Manage Dependency Setting is disabled.');
                    continue;
                }
                if(markChangeToken(newWO, oldWO, svmxProcessMap)){
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::identifyAPIAndOptimize()::WorkOrder: '+newWO.Id+' Qualified for : '+newWO.SVMXC__Scheduling_Change_Token__c);
                    woFieldValuesMap.put('PROCESS_FURTHER', true);
                    //mapWoSchToken.put(newWO.id, newWO.SVMXC__Scheduling_Change_Token__c);
                    updatedWoSet.add(newWO);
                    newWO.SVMXC__OptiMax_Status__c = isFutureContext? WSCH_Constants.STATUS_OPT_BATCH : WSCH_Constants.STATUS_OPT_PENDING;
                    updateWoOptStatus(newWO);
                    newWO.SVMXC__Scheduling_Retry_Count__c = 0;
                    startBatch = true;
                //Below else part is commented. The reason for this is even the WO's which are not qualify for any token.
                /*} else {
                    //add the newWO to updatedWoSet even if it does not qualify for markChangeToken. These WO's will be checked
                    // later to see if there are any changes in their formula field values.
                    updatedWoSet.add(newWO);*/
                }
            }
            
            //Add details of Workorders which are re-booked due to change in WorkOrder Resource Preference to the map to serialize and pass to asynchronous context.
            if('CHANGE_RESOURCE_PREFERENCE'.equalsIgnoreCase(oldWO.SVMXC__Scheduling_Change_Token__c)){
                woFieldValuesMap.put('SVMXC__OptiMax_Status__c', oldWO.SVMXC__OptiMax_Status__c);
                woFieldValuesMap.put('SVMXC__Scheduling_Change_Token__c', oldWO.SVMXC__Scheduling_Change_Token__c);
                woFieldValuesMap.put('WOId', oldWO.Id);
            }
            serializedWOInfo.add(JSON.serialize(woFieldValuesMap));
            
        }
        
        //To delete workorder related events if the token is "CHANGE_CANCEL_WO"
        if(updatedWoSet.size() > 0){
            WSCH_CommonUtils.deleteWORelatedEventsOnCancel(updatedWoSet);   
        }        

        //updatedWoSet      --> Set of Linx workorders which is having packaged fields changes and its corresponding token.
        //linxWOsSet        --> Set of Linx workorder Ids only.
        //lstOfCustomFields --> List of custome fields from the Settings(to invoke BookJob and UpdateJob Api calls)
        if(updatedWoSet.size() > 0 || (lstOfCustomFields != null && lstOfCustomFields.size() > 0 && linxWOsSet.size() > 0 ))
        {
            //check source call is future or batch and to avoid further future call.
            if(isFutureContext ) {
                if(startBatch)
                {
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::identifyAPIAndOptimize()::Source is a FutureCall/Batch, So mark the workOrder for Batch execution : serializedWOInfo '+serializedWOInfo);
                    WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.WO_BATCH_CLASS_NAME, WSCH_Constants.BATCH_APEX_START_TIME);
                }
            } else {
                WSCH_AuditLogger.debug('WSCH_TriggerHandler::identifyAPIAndOptimize()::invoke future call with serializedWOInfo '+serializedWOInfo);
                if(!mapWoSchToken.isEmpty() && ((isSmaxQSettingEnabled != null) && (isSmaxQSettingEnabled))){
                    Map<String, SVMXC__Service_Order__c> mapNewWo = new Map<String, SVMXC__Service_Order__c>();
                    SVMXC__Service_Order__c oldWoRec = new SVMXC__Service_Order__c();
                    for(SVMXC__Service_Order__c woRec: newWoList){
                        mapNewWo.put(woRec.name, woRec);
                    }
                    List<SVMXC__Service_Order__c> lstNewWO = new List<SVMXC__Service_Order__c> ();
                    //fetch the list of work orders to be processed
                    lstNewWO = WSCH_CommonUtils.fetchWorkOrders(new List<String>(mapWoSchToken.keySet()));
                    String strUpdatedSchedToken, schedToken, schedValue;
                    //loop through the newly fetched work orders list, these work orders will have updated formula field values
                    for(SVMXC__Service_Order__c newWoRec: lstNewWO){
                        //loop through the work orders passed from trigger, these work orders will have old formula values
                        oldWoRec = mapNewWo.get(newWoRec.name);
                            if((oldWoRec != null) && (newWoRec.name.equalsIgnoreCase(oldWoRec.name))){
                                //get the scheduling token for work order from map, this token will be later used for comparison
                                strUpdatedSchedToken = mapWoSchToken.get(String.valueOf(newWoRec.Id));
                                //fetch the scheduling token for work order from map, this will be used for processing
                                schedToken =  mapWoSchToken.get(String.valueOf(newWoRec.Id));
                                //if the scheduling token has a field value as well then spilt the token  and value
                                if((schedToken.containsIgnoreCase('CHANGE_JOB_FIXED') &&schedToken.containsIgnoreCase(',')) ||
                                 (schedToken.containsIgnoreCase('CHANGE_SERVICE_DURATION') &&schedToken.containsIgnoreCase(',')) ||
                                 (schedToken.containsIgnoreCase('CHANGE_SCHEDULING_STATUS') &&schedToken.containsIgnoreCase(','))){
                                    schedValue = schedToken.split(',')[1];
                                    schedToken = schedToken.split(',')[0];
                                 }
                                 //send scheduling token to check for formula field changes
                                schedToken = isCustomFieldChangeSmaxQ(oldWoRec, newWoRec, schedToken);
                                //if the old & new token are same, then assign the same to the map
                                if(strUpdatedSchedToken.equalsIgnoreCase(schedToken + ',' + schedValue)){
                                    schedToken = strUpdatedSchedToken;
                                }
                                mapWoSchToken.put(String.valueOf(newWoRec.Id), schedToken);
                            }
                    }
                    //create optmimizer transaction record for the map of work order & respective scheduling token
                    createOptTrans(mapWoSchToken);                  
                }
                if((isSmaxQSettingEnabled != null) &&(!isSmaxQSettingEnabled)){
                    manageWorkOrders(serializedWOInfo);
                }
            }
        }
        WSCH_AuditLogger.finish();
        System.debug('End of WSCH_TriggerHandler::identifyAPIAndOptimize():No of Queries used in this trigger code so far: ' + Limits.getQueries());        
    }

    // Qualification Logic for Force Fix work order
    public static boolean isFixWO(SVMXC__Service_Order__c newWO, SVMXC__Service_Order__c oldWO) {
        Boolean forceFix=false;
        Set<String> allowedSchedulingStatus = new Set<String> {'Tentative','Dispatched','Fixed'};

        //Based on the DC behaviour the following logic implemented.
        //The following is the sequence.
        //1. Un Assigning existing technician
        //2. Assigning new technician
        //3. Updating Schedule Date Time.
        //So check the schedule datetime instead of checking technician changes in wo
        
        //DC move job with different technician - 3rd update - forceFix set to 'True'
        //DC move job with same technician - forceFix set to 'True'
        
        System.debug('1-->'+oldWO.SVMXC__Scheduled_Date_Time__c+'2-->'+newWO.SVMXC__Scheduled_Date_Time__c+'3-->'+newWO.SVMXC__Driving_Time__c+'4-->'+oldWO.SVMXC__Scheduled_Date_Time__c);
        if(newWO.SVMXC__Scheduled_Date_Time__c != null && oldWO.SVMXC__Scheduled_Date_Time__c != newWO.SVMXC__Scheduled_Date_Time__c){            
            
            if(oldWO.SVMXC__Scheduled_Date_Time__c != null){
            
                Integer changeInStartTimeInMinutes = integer.valueof(Math.abs(((newWO.SVMXC__Scheduled_Date_Time__c).getTime() - (oldWO.SVMXC__Scheduled_Date_Time__c).getTime())/60000L));
                Integer oldDriveTime=0, newDriveTime=0;
                if(oldWO.SVMXC__Driving_Time__c != null){
                    oldDriveTime = Integer.valueOf(oldWO.SVMXC__Driving_Time__c);
                }
                if(newWO.SVMXC__Driving_Time__c != null){
                    newDriveTime = Integer.valueOf(newWO.SVMXC__Driving_Time__c);
                }                
                Integer changeInDrivingTime = Math.abs(newDriveTime - oldDriveTime);
                System.debug('5-->'+changeInStartTimeInMinutes +'6-->'+changeInDrivingTime );
                WSCH_AuditLogger.debug('WSCH_TriggerHandler::isFixWO()::WorkOrder: 1-->'+oldWO.SVMXC__Scheduled_Date_Time__c+'2-->'+newWO.SVMXC__Scheduled_Date_Time__c+'3-->'+newWO.SVMXC__Driving_Time__c+'4-->'+oldWO.SVMXC__Driving_Time__c);
                WSCH_AuditLogger.debug('WSCH_TriggerHandler::isFixWO()::TimeDiff: 1-->'+changeInStartTimeInMinutes +'2-->'+changeInDrivingTime);
                if(changeInStartTimeInMinutes == changeInDrivingTime){
                forceFix = false;
                }
            else{
                forceFix=true;
                isForceFixSchedDate = true;
            }
        }
        else{
                forceFix=true;
            }
    }
        
        if(newWO.SVMXC__Locked_By_DC__c == true)
        {
            //SFM scenario - forceFix set to 'True'
            if(newWO.SVMXC__Locked_By_DC__c != oldWO.SVMXC__Locked_By_DC__c)
                forceFix = true;
            
            //DC move job with different technician - 2nd update - skip
            if(newWO.SVMXC__Group_Member__c != oldWO.SVMXC__Group_Member__c )
                forceFix=false;
        }
        
        if(forceFix && allowedSchedulingStatus.contains(newWO.SVMXC__Work_Order_Scheduling_Status__c)){
            if(newWO.SVMXC__Locked_By_DC__c != true){
                WSCH_AuditLogger.debug('LockedByDC flag set to True if DC not set the flag.');
                newWO.SVMXC__Locked_By_DC__c=true;
            }
        } else {
            forceFix=false;
        }
        return forceFix;
    }

    public static boolean markChangeToken (SVMXC__Service_Order__c newWO, SVMXC__Service_Order__c oldWO, Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap) {

        Boolean isQualifyAndMark = false;
        Boolean isCancelledWO = false;
        Boolean isValidDP = false;
        Set<Id> setWoIds = new Set<Id>();
        //Set of Scheduling Statuses from which ForceFix call should be allowed.
        Set<String> setWODispStatus = new Set<String>(WSCH_Constants.WO_SMax_DISPATCH_STATUS);
        setWoIds.add(newWO.id);
        //Below check has been commented as we have move this check in the begining of identifyAPIAndOptimize().
        //The reason for this is even the WO's which are not qualifying for SP were sent to future call for further processing.
       /* //Allowing updates both types of jobs. Jobs booked through Book Job or Book Appointment.
        if(newWO.SVMXC__Schedule_As_A_Dependent_Work_Order__c && newWO.SVMXC__Dependency_Group__c == null){
            return isQualifyAndMark;
        }
        if (!(isBookJobWO(newWO, svmxProcessMap) || isAppointmentWO(newWO) || newWO.SVMXC__Dependency_Group__c != null)) {
            return isQualifyAndMark;
        }*/
        //check if Technician MPX Calculation is Turned On
        Boolean isResPrefEnabled = WORD_Service_Order_Resources.getResourcePreferenceSetting();
        Boolean isResPrefMapHasWo = false;
        //check if the new Work Order qualifies for MPX recalculation
        if((WORD_Service_Order_Resources.mapIsWoResEmpty != null) && WORD_Service_Order_Resources.mapIsWoResEmpty.containsKey(newWO.id)){
            isResPrefMapHasWo = WORD_Service_Order_Resources.mapIsWoResEmpty.get(newWO.id);
        }
        //Check if the Work Order is Successfully cancelled Work Order
        if((oldWo.SVMXC__Work_Order_Scheduling_Status__c != null) &&
           (newWO.SVMXC__Work_Order_Scheduling_Status__c != null) &&
           ('Cancelled'.equalsIgnoreCase(oldWo.SVMXC__Work_Order_Scheduling_Status__c)) &&
           (oldWo.SVMXC__OptiMax_Status__c == WSCH_Constants.STATUS_OPT_COMPLETED)){
               isCancelledWO = true;
               WSCH_AuditLogger.debug('Cancelled WO: ' + newWO.Name);
           }
        //check if the new work order has a valid Linx for SP Dispatch Process
        if(newWO.SVMXC__Dispatch_Process__c != null){
                if(svmxProcessMap.ContainsKey(newWO.SVMXC__Dispatch_Process__c)) {
                    isValidDP = true;
                }
            } 
        
        String schedulingChangeToken = '';
        /* Qualification logic for CancelJob changes : 'CHANGE_CANCEL_WO' */
        if(newWO.SVMXC__Order_Status__c == 'Canceled' && oldWO.SVMXC__Order_Status__c != 'Canceled'){
            schedulingChangeToken = 'CHANGE_CANCEL_WO';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Canceled_Date_Time__c != oldWO.SVMXC__Canceled_Date_Time__c && newWO.SVMXC__Canceled_Date_Time__c != null){
            schedulingChangeToken = 'CHANGE_CANCEL_WO';
            isQualifyAndMark = true;
        } else if(newWo.SVMXC__Work_Order_Scheduling_Status__c != oldWo.SVMXC__Work_Order_Scheduling_Status__c && 'Cancelled'.equalsIgnoreCase(newWo.SVMXC__Work_Order_Scheduling_Status__c)){
            schedulingChangeToken = 'CHANGE_CANCEL_WO';
            isQualifyAndMark = true;
        } else if(oldWo.SVMXC__Group_Member__c != null && newWo.SVMXC__Group_Member__c == null && !WSCH_OptimizedSchedulingService.isUnAssignDC ){
            schedulingChangeToken = 'CHANGE_CANCEL_WO';
            isQualifyAndMark = true;
        /*
            Only allowed to be rebooked when job is not fixed.
            Qualification logic for Rebook changes : 'CHANGE_CREATE_WO' ,'CHANGE_ZIP_CODE' , 'CHANGE_SKILL_SET' , 'CHANGE_SERVICE_DURATION' ,
            'CHANGE_PREFERRED_TECH' , 'CHANGE_ACCESS_HOURS' , 'CHANGE_START_TIME' , 'CHANGE_END_TIME' , 'CHANGE_DISPATCH_PROCESS'
        */
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c =='New' && newWO.SVMXC__Scheduling_Change_Token__c == null){ //Dispatch Statud is New then create wo
            schedulingChangeToken = 'CHANGE_CREATE_WO';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Zip__c != oldWo.SVMXC__Zip__c){
            schedulingChangeToken = 'CHANGE_ZIP_CODE';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Skill_Set__c != oldWo.SVMXC__Skill_Set__c){
            schedulingChangeToken = 'CHANGE_SKILL_SET';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Service_Duration__c != oldWo.SVMXC__Service_Duration__c){
            schedulingChangeToken = 'CHANGE_SERVICE_DURATION';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Preferred_Technician__c != oldWo.SVMXC__Preferred_Technician__c){
            schedulingChangeToken = 'CHANGE_PREFERRED_TECH';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Preferred_Business_Hours__c != oldWo.SVMXC__Preferred_Business_Hours__c){
            schedulingChangeToken = 'CHANGE_ACCESS_HOURS';
            isQualifyAndMark = true;
        } else if(!newWO.SVMXC__Locked_By_DC__c && newWO.SVMXC__Preferred_Start_Time__c != oldWo.SVMXC__Preferred_Start_Time__c){
            schedulingChangeToken = 'CHANGE_PREFERRED_TIME';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Preferred_End_Time__c != oldWo.SVMXC__Preferred_End_Time__c){
            schedulingChangeToken = 'CHANGE_PREFERRED_TIME';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && isValidDP && newWO.SVMXC__Dispatch_Process__c != oldWo.SVMXC__Dispatch_Process__c){
            schedulingChangeToken = 'CHANGE_DISPATCH_PROCESS';
            isQualifyAndMark = true;
        } /*else if(newWO.SVMXC__Locked_By_DC__c == false && 'FORCE_SCHEDULE'.equalsIgnoreCase(oldWo.SVMXC__Scheduling_Change_Token__c)) {
            schedulingChangeToken = 'FORCE_SCHEDULE';
            isQualifyAndMark = true;
        }*/ else if(newWO.SVMXC__Locked_By_DC__c == false && 'CHANGE_RESOURCE_PREFERENCE'.equalsIgnoreCase(oldWo.SVMXC__Scheduling_Change_Token__c)) {
            schedulingChangeToken = 'CHANGE_RESOURCE_PREFERENCE';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false  &&  (isResPrefEnabled) && (isResPrefMapHasWo) && (newWO.SVMXC__Component__c != oldWo.SVMXC__Component__c)) {
            schedulingChangeToken = 'CHANGE_COMPONENT_RESOURCE';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false  && (isResPrefEnabled) && (isResPrefMapHasWo) && (newWO.SVMXC__Site__c != oldWo.SVMXC__Site__c)) {
            schedulingChangeToken = 'CHANGE_SITE_RESOURCE';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false  && (isResPrefEnabled) && (isResPrefMapHasWo) && (newWO.SVMXC__Company__c != oldWo.SVMXC__Company__c)) {
            schedulingChangeToken = 'CHANGE_ACCOUNT_RESOURCE';
            isQualifyAndMark = true;
        }   else if(isCustomFieldChange(newWO,oldWO,WSCH_Constants.API_BOOK_JOB)){
            schedulingChangeToken = 'CHANGE_CUSTOM_FIELDS_BOOK';
            isQualifyAndMark = true;
        /*
            Only allowed to update the job when it is not booked using Book Appt API.
            Qualification logic for Updatejob changes : 'CHANGE_CONTACT_INFO','CHANGE_PRIORITY','CHANGE_UNFIXED'
        */
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Locked_By_DC__c != oldWO.SVMXC__Locked_By_DC__c) {
            schedulingChangeToken = 'CHANGE_JOB_UNFIXED';
            isQualifyAndMark = true;
        } else if(!isAppointmentWO(newWO) && newWO.SVMXC__Dispatch_Priority__c != oldWo.SVMXC__Dispatch_Priority__c){
            schedulingChangeToken = 'CHANGE_PRIORITY';
            isQualifyAndMark = true;
        } else if(!isAppointmentWO(newWO) && newWO.SVMXC__Contact__c != oldWo.SVMXC__Contact__c) {
            schedulingChangeToken = 'CHANGE_CONTACT_INFO';
            isQualifyAndMark = true;
        } else if(!isAppointmentWO(newWO) && newWO.SVMXC__Company__c != oldWo.SVMXC__Company__c) {
            schedulingChangeToken = 'CHANGE_ACCOUNT_INFO';
            isQualifyAndMark = true;
        } else if(!isAppointmentWO(newWO) && isAddressInfoChange(newWO, oldWO)) {
            schedulingChangeToken = 'CHANGE_ADDRESS_INFO';
            isQualifyAndMark = true;
        } else if(!isAppointmentWO(newWO) && isCustomFieldChange(newWO,oldWO,WSCH_Constants.API_UPDATE_JOB)){
            schedulingChangeToken = 'CHANGE_CUSTOM_FIELDS_UPDATE';
            isQualifyAndMark = true;            
            
        /* Qualification logic for Work items status changes :'CHANGE_STATUS','CHANGE_SCHEDULING_STATUS' */
        } else if(newWO.SVMXC__Acknowledged_By_Technician_Date_Time__c != oldWo.SVMXC__Acknowledged_By_Technician_Date_Time__c){
            schedulingChangeToken = 'CHANGE_STATUS';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Started_Driving_To_Location_Date_Time__c != oldWo.SVMXC__Started_Driving_To_Location_Date_Time__c){
            schedulingChangeToken = 'CHANGE_STATUS';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Actual_Onsite_Response__c != oldWo.SVMXC__Actual_Onsite_Response__c){
            schedulingChangeToken = 'CHANGE_STATUS';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Finished_Onsite_Date_Time__c != oldWo.SVMXC__Finished_Onsite_Date_Time__c){
            schedulingChangeToken = 'CHANGE_STATUS';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Completed_Date_Time__c != oldWo.SVMXC__Completed_Date_Time__c) {
            schedulingChangeToken = 'CHANGE_STATUS';
            isQualifyAndMark = true;
        } else if((!isCancelledWO) && (setWODispStatus.contains(oldWo.SVMXC__Work_Order_Scheduling_Status__c)) && (newWO.SVMXC__Work_Order_Scheduling_Status__c == 'Fixed')){
            schedulingChangeToken = 'CHANGE_JOB_STATUS_FIXED';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Work_Order_Scheduling_Status__c != oldWo.SVMXC__Work_Order_Scheduling_Status__c){
            schedulingChangeToken = 'CHANGE_SCHEDULING_STATUS';
            isQualifyAndMark = true;
        }

        if (newWO.SVMXC__Locked_By_DC__c != false && schedulingChangeToken == '') {
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::markChangeToken:: Skip this update for ForceFix Call/Job is already Fixed. Any changes to the fields affecting scheduling should not be performed.');
            String errorText = 'Skip this update for ForceFix Call./Job is already Fixed, So any changes to the fields affecting scheduling should not be performed.';
            WSCH_CommonUtils.setOptimizerErrorText(newWO, errorText);
        }
        
        /*new change token introduced for Book Dependency API call 
        */
        if(WSCH_Constants.BOOKJOB_SCHDL_CHANGE_TOKENS.contains(schedulingChangeToken) && newWO.SVMXC__Dependency_Group__c != null){
            schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;                
        }
        
        if(schedulingChangeToken.equals('CHANGE_CANCEL_WO') && newWO.SVMXC__Dependency_Group__c != null){
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::markChangeToken:: Skip this update for cancel Job because it is scheduled to be part of dependency group');
            String errorText = 'Job is scheduled to be part of dependency group, first cancel the dependency manually and try again';
            WSCH_CommonUtils.setOptimizerErrorText(newWO, errorText);
            isQualifyAndMark = false;
        }

        /*
            If existing SVMXC__Scheduling_Change_Token__c is of higher priority then the new Scheduling change token, Then this function doesn't update it.
        */
        if (isQualifyAndMark) {
            newWO.SVMXC__Scheduling_Change_Token__c = getChangeToken(oldWO.SVMXC__OptiMax_Status__c,oldWO.SVMXC__Scheduling_Change_Token__c,schedulingChangeToken);
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::markChangeToken::Scheduling Change Token : '+newWO.SVMXC__Scheduling_Change_Token__c);
        }
        String strSchedToken = '';
        if((isQualifyAndMark) && (newWO.SVMXC__OptiMax_Status__c != WSCH_Constants.STATUS_OPT_BATCH) && ((isSmaxQSettingEnabled != null) && (isSmaxQSettingEnabled))){
            //newWO.SVMXC__Scheduling_Change_Token__c = isCustomFieldChangeSmaxQ(newWO, newWO.SVMXC__Scheduling_Change_Token__c);
            strSchedToken = newWO.SVMXC__Scheduling_Change_Token__c;
            if(strSchedToken.equalsIgnoreCase('CHANGE_SERVICE_DURATION')){
                strSchedToken = strSchedToken + ',' + String.valueOf(newWO.SVMXC__Service_Duration__c);
            }else if(strSchedToken.equalsIgnoreCase('CHANGE_SCHEDULING_STATUS')){
                strSchedToken = strSchedToken + ',' + String.valueOf(newWO.SVMXC__Work_Order_Scheduling_Status__c);
            }
            mapWoSchToken.put(newWO.id, strSchedToken);         
        }
        return isQualifyAndMark;
    }

    // Qualification logic for BookJob work order related changes
    public static boolean isBookJobWO(SVMXC__Service_Order__c newWO, Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap) {

        Boolean isSlaWO = false;
        if(newWO != null && newWO.SVMXC__Appointment_Promised_Time_Slot__c != null){
            String[] apptPromiseSlotArray = newWO.SVMXC__Appointment_Promised_Time_Slot__c.split(',',7);
            if(apptPromiseSlotArray.size() > 3){
                if(apptPromiseSlotArray[3].trim().equals('false')) {
                    isSlaWO = true;
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::isBookJobWO: ' + isSlaWO + 'AppointmentSlot: ' + apptPromiseSlotArray[3].trim());
                }
            }
        }else{
            if(newWO != null && newWO.SVMXC__Dispatch_Process__c != NULL){
                if(svmxProcessMap.ContainsKey(newWO.SVMXC__Dispatch_Process__c)) {
                    isSlaWO = true;
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::isBookJobWO: ' + isSlaWO + 'Dispatch Process: ' + svmxProcessMap);
                }
            }           
        }
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::isBookJobWO: ' + isSlaWO);
        return isSlaWO;
    }

    // Qualification logic for work order custom fields changes for rebook and update job
    public static boolean isCustomFieldChange(SVMXC__Service_Order__c newWO, SVMXC__Service_Order__c oldWO, String apiName){
        Boolean isFieldChange = false;
        String strCustomFields;
        if(apiName.equals(WSCH_Constants.API_BOOK_JOB)){
            //rCustomFields = WSCH_CommonUtils.getSettingValue('DCON004','SET009'); 
            if(String.isNotEmpty(strBookJobCustomFields)) {
                strCustomFields = strBookJobCustomFields;
            }
        }else if(apiName.equals(WSCH_Constants.API_UPDATE_JOB)){
            //strCustomFields = WSCH_CommonUtils.getSettingValue('DCON004','SET008');
            if(String.isNotEmpty(strUpdateJobCustomFields)) {
                strCustomFields = strUpdateJobCustomFields;
            }
        }
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::isCustomFieldChange::strCustomFields - ' + strCustomFields);
        if(String.isNotBlank(strCustomFields)){
            String[] customFieldsSplit = strCustomFields.split(',');
            for(String changeField : customFieldsSplit){
                if(newWO.get(changeField.trim()) != oldWo.get(changeField.trim())) {
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::isCustomFieldChange::changeField :'+changeField.trim());
                    isFieldChange = true; 
                    break;
                }
            }
        }
        return isFieldChange;
    }
    
    /*Method to detect changes in WO's Street, City, State, Country */
    public static Boolean isAddressInfoChange(SVMXC__Service_Order__c newWO, SVMXC__Service_Order__c oldWO){
        Boolean isAddressChange= false;
        List<String> addrFields = new List<String>{'SVMXC__Country__c','SVMXC__City__c','SVMXC__State__c','SVMXC__Street__c'};
        for(String aField: addrFields){
            if(newWO.get(aField) !=  oldWo.get(aField)){
                isAddressChange = true;
                break;
            }
        }
        return isAddressChange;
    }
    public static Set<String> getBookJobFieldsFromSettings() {
        Set<String> bookJobCustFieldsSet = new Set<String>();
        
        //String strCustomFields = WSCH_CommonUtils.getSettingValue('DCON004','SET009');  //bookJob fields
        String strCustomFields = strBookJobCustomFields;
        //below code adds only the rebookJob custom fields into bookJobCustFieldsSet Set
        if(String.isNotBlank(strCustomFields)) {
            String[] customFieldsSplit = strCustomFields.split(',');
            for(String changeField : customFieldsSplit){
                bookJobCustFieldsSet.add(changeField);
            }
        }
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::getCustomFieldsFromSettings::bookJobCustFieldsSet : ' + bookJobCustFieldsSet);
        return bookJobCustFieldsSet;
    }
    
    public static Set<String> getUpdateJobFieldsFromSettings() {    
        Set<String> UpdateJobCustFieldsSet = new Set<String>();
        //adding the updateJob custom fields also to the strCustomFields
        //String strCustomFieldsUpdate = WSCH_CommonUtils.getSettingValue('DCON004','SET008');   //updateJob fields
        String strCustomFieldsUpdate = strUpdateJobCustomFields;
        if(String.isNotBlank(strCustomFieldsUpdate)) {
            String[] customFieldsSplit = strCustomFieldsUpdate.split(',');
            for(String changeField : customFieldsSplit){
                UpdateJobCustFieldsSet.add(changeField);
            }
        }
        //WSCH_AuditLogger.debug('WSCH_TriggerHandler::getCustomFieldsFromSettings::UpdateJobCustFieldsSet : ' + UpdateJobCustFieldsSet);
        return UpdateJobCustFieldsSet;
    }
    
    public static List<String> getCustomFieldsFromSettings(){
        List<String> lstOfCustomFields = new List<String>();
        lstOfCustomFields.addAll(getBookJobFieldsFromSettings());
        lstOfCustomFields.addAll(getUpdateJobFieldsFromSettings());
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::getCustomFieldsFromSettings::lstOfCustomFields : ' + lstOfCustomFields);
        return lstOfCustomFields;
    }       
    
    // Qualification logic for Book appointment work order related changes
    public static boolean isAppointmentWO(SVMXC__Service_Order__c newWO) {

        Boolean isApptWO = false;
        if(newWO != null && newWO.SVMXC__Appointment_Promised_Time_Slot__c != null){
            String[] apptPromiseSlotArray = newWO.SVMXC__Appointment_Promised_Time_Slot__c.split(',',7);
            if(apptPromiseSlotArray.size() > 3){
                if(apptPromiseSlotArray != null && apptPromiseSlotArray[3].trim().equals('true')) {
                    isApptWO = true;
                }
            }
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::isAppointmentWO::isApptWO :'+isApptWO);
        }
        return isApptWO;
    }
    
    public static boolean isForceScheduleBookedWO(SVMXC__Service_Order__c oldWO) {
        //Set<String> strSetValidOptStatus = new Set<String>{WSCH_Constants.STATUS_OPT_FAIL, WSCH_Constants.STATUS_OPT_ERROR, WSCH_Constants.STATUS_OPT_COMPLETED, WSCH_Constants.STATUS_OPT_DATA_SYNC_ERROR};
        Set<String> strWOSchedulingStatus = new Set<String>{'--None--','SVMX.NONE','SVMX.None', null};
        
        Boolean isForceScheduleBooked = false;
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::isForceScheduleBookedWO::oldWO.SVMXC__OptiMax_Status__c - ' + oldWO.SVMXC__OptiMax_Status__c);
        /*if(oldWO != null && oldWO.SVMXC__Scheduling_Change_Token__c != null && strSetValidOptStatus.contains(oldWO.SVMXC__OptiMax_Status__c)) {
            isForceScheduleBooked = true;
        }*/
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::isForceScheduleBookedWO::oldWO.SVMXC__Work_Order_Scheduling_Status__c - ' + oldWO.SVMXC__Work_Order_Scheduling_Status__c);
        WSCH_AuditLogger.debug('WSCH_Constants.BOOKJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c) -' + WSCH_Constants.BOOKJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c));
        WSCH_AuditLogger.debug('WSCH_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c) - ' + WSCH_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c));
        WSCH_AuditLogger.debug('WSCH_Constants.FORCEFIXJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c) -' + WSCH_Constants.FORCEFIXJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c));
        WSCH_AuditLogger.debug('WSCH_Constants.CHANGESTATUS_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c) - ' + WSCH_Constants.CHANGESTATUS_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c));
        //WSCH_AuditLogger.debug('oldWO.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase(\'FORCE_SCHEDULE\') - ' + oldWO.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase('FORCE_SCHEDULE'));
        WSCH_AuditLogger.debug('strWOSchedulingStatus.contains(oldWO.SVMXC__Work_Order_Scheduling_Status__c) - ' + strWOSchedulingStatus.contains(oldWO.SVMXC__Work_Order_Scheduling_Status__c));
        
        if(oldWO != null && oldWO.SVMXC__Scheduling_Change_Token__c != null && (WSCH_Constants.BOOKJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c)
                || WSCH_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c) 
                    || WSCH_Constants.FORCEFIXJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c) 
                        || WSCH_Constants.CHANGESTATUS_TOKENS.contains(oldWO.SVMXC__Scheduling_Change_Token__c) 
                            || (String.isNotBlank(oldWO.SVMXC__Scheduling_Change_Token__c) && oldWO.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase('FORCE_SCHEDULE'))) 
                                && !(strWOSchedulingStatus.contains(oldWO.SVMXC__Work_Order_Scheduling_Status__c))) {
            isForceScheduleBooked = true;
        }
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::isForceScheduleBookedWO: ' + isForceScheduleBooked);
        return isForceScheduleBooked;
   }

    /**
        Following method will be called from Work Order trigger on delete of work orders.
    **/
    public static void doQualifyCancelWorkorder(List<SVMXC__Service_Order__c> workorderList) {

        try{
            //get the type of source call
            boolean isFutureContext = System.isBatch() || System.isFuture();
            //get the qualified workorder ids.
            //List<String> qualifiedWOIds = getQualifiedCancelWOIds(workorderList);
            Map<String, String> mapOfqualifiedWoNameIds = getQualifiedCancelWOIds(workorderList);
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQualifyCancelWorkorder(): Qualified mapOfqualifiedWoNameIds for delete :'+mapOfqualifiedWoNameIds);
            
            /*
            List<SVMXC__Service_Order_Dependency__c> getDependencyRecords = new List<SVMXC__Service_Order_Dependency__c>();
            List<String> WoIds = new List<String>();
            List<String> dependencyIds = new List<String>();
            List<SVMXC__Service_Order__c> workOrdersInSameDependencyPair = new List<SVMXC__Service_Order__c>();
            List<SVMXC__Service_Order__c> workOrdersToUpdate = new List<SVMXC__Service_Order__c>();
            for (SVMXC__Service_Order__c woId : workorderList){
                WoIds.add(woId.Id);
            }
            getDependencyRecords = [SELECT Id, Name, SVMXC__Primary_Work_Order__c, SVMXC__Secondary_Work_Order__c, SVMXC__Dependency_Group__c FROM SVMXC__Service_Order_Dependency__c WHERE SVMXC__Primary_Work_Order__c IN: WoIds OR SVMXC__Secondary_Work_Order__c IN: WoIds];
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQualifyCancelWorkorder(): Related dependency record :'+getDependencyRecords);
            for(SVMXC__Service_Order_Dependency__c dependencyRecord: getDependencyRecords){
                dependencyIds.Add(dependencyRecord.SVMXC__Primary_Work_Order__c);
                dependencyIds.Add(dependencyRecord.SVMXC__Secondary_Work_Order__c);
            }
            workOrdersInSameDependencyPair = [SELECT Id, SVMXC__Dependency_Group__c FROM SVMXC__Service_Order__c where Id IN: dependencyIds];
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQualifyCancelWorkorder: Dependency WOs: '+workOrdersInSameDependencyPair);
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            if(workOrdersInSameDependencyPair.size() >0){
                for(SVMXC__Service_Order__c updateWoRecord: workOrdersInSameDependencyPair){
                    updateWoRecord.SVMXC__Dependency_Group__c = null;
                    workOrdersToUpdate.add(updateWoRecord);
                }
                update workOrdersToUpdate;      
            }   */   
            //creating a list of WO Ids from the map<woName, Id>
            List<String> qualifiedWONames;
            Set<String> woNameSet = new Set<String>();
            if(mapOfqualifiedWoNameIds != null && mapOfqualifiedWoNameIds.size() > 0) {
                woNameSet = mapOfqualifiedWoNameIds.keySet();
                /*for(String eachWOName : woNameSet) {
                    qualifiedWOIds.add(mapOfqualifiedWoNameIds.get(eachWOName));
                }*/
            }
            
            if(woNameSet != null && woNameSet.size() > 0) {
                qualifiedWONames = new List<String>(woNameSet);
            }
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQualifyCancelWorkorder(): Qualified WONames for delete :'+qualifiedWONames);
            
            //if(qualifiedWOIds.size() > 0){
            if(mapOfqualifiedWoNameIds != null && mapOfqualifiedWoNameIds.size() > 0){
                list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = new list<SVMXC__SVMX_Optimizer__c>();
                //for (String woId : qualifiedWOIds) {
                for (String eachWoName : qualifiedWONames) {

                    SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
                    optimizer.SVMXC__WhatId__c = eachWoName;                   
                    optimizer.SVMXC__WhatType__c = 'WORK_ORDER';
                    optimizer.SVMXC__SM_Work_Order__c = mapOfqualifiedWoNameIds.get(eachWoName);
                    optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CANCEL_WO';
                    optimizer.SVMXC__Optimizer_Status__c = isFutureContext? WSCH_Constants.STATUS_OPT_BATCH : WSCH_Constants.STATUS_OPT_PENDING;
                    optimizer.SVMXC__Optimizer_Retry_Count__c = 0;
                    lstSVMXOptimizer.add(optimizer);
                }
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSVMXOptimizer, COMM_SecurityUtils.Access.Createable)){     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    insert lstSVMXOptimizer;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
                
                //check source call is future or batch and to avoid further future call.
                if(isFutureContext) {
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQualifyCancelWorkorder()::Source is a FutureCall/Batch, So mark the workOrder for Batch execution :'+qualifiedWONames);
                    WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.CANCEL_WO_BATCH_APEX, WSCH_Constants.BATCH_APEX_START_TIME);
                } else {
                    cancelWorkOrders(qualifiedWONames);
                }
            }
            WSCH_AuditLogger.finish();
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_TriggerHandler:doQualifyCancelWorkorder() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    /**
        Following method is to check , whether work order is scheduled or created using continous optimization.
        In current implementation , it is validated by checking whether the SVMXC__OptiMax_Status__c is not null.
     **/
    /*public static List<String> getQualifiedCancelWOIds(List<SVMXC__Service_Order__c> workorderList){

        List<String> qualifiedWOIds = new list<String>();
        Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap = WSCH_CommonUtils.getContinuousDP();
        for(SVMXC__Service_Order__c workOrder : workorderList) {
            if(workOrder.SVMXC__OptiMax_Status__c != null && !('Canceled'.equalsIgnoreCase(workOrder.SVMXC__Order_Status__c))) {
                if (!(isBookJobWO(workOrder, svmxProcessMap) || isAppointmentWO(workOrder) || isForceScheduleBookedWO(workOrder))) {
                    continue;
                }
                qualifiedWOIds.add(WSCH_CommonUtils.getWorkItemId('Name',workOrder));
            }
        }
        return qualifiedWOIds;
    }*/
    
    //Commented the above method. Added this method to return the Map<woName, Id>
    public static Map<String, String> getQualifiedCancelWOIds(List<SVMXC__Service_Order__c> workorderList){

        Map<String, String> mapOfWoNameWoId = new Map<String, String>();
        Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap = WSCH_CommonUtils.getContinuousDP();
        for(SVMXC__Service_Order__c workOrder : workorderList) {
            if(workOrder.SVMXC__OptiMax_Status__c != null && !('Canceled'.equalsIgnoreCase(workOrder.SVMXC__Order_Status__c))) {
                if (!(isBookJobWO(workOrder, svmxProcessMap) || isAppointmentWO(workOrder) || isForceScheduleBookedWO(workOrder))) {
                    continue;
                }
                mapOfWoNameWoId.put(WSCH_CommonUtils.getWorkItemId('Name',workOrder), workOrder.Id);
            }
        }
        return mapOfWoNameWoId;
    }

    /**
        Following method is a future method to be called to cancel a WO.
        This method is invoking abstract service cancelWorkOrders method.
     **/
    @future(callout=true)
    public static void cancelWorkOrders(List<String> qualifiedWONames){

        /*
          Calling Abstract services method to cancel the work orders.
         */
        try{
            list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = WSCH_CommonUtils.fetchSVMXOptimizerByWhatId(qualifiedWONames);
            WSCH_AuditLogger.debug('WSCH_TriggerHandler:cancelWorkOrders(): lstSVMXOptimizer - ' + lstSVMXOptimizer);
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            WSCH_OptimizedSchedulingService.cancelWorkOrders(lstSVMXOptimizer);
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_TriggerHandler:cancelWorkOrders() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    /**
        Following method validates whether the new SVMXC__Scheduling_Change_Token__c should be updated.
     **/
    public static String getChangeToken (String currentStatus,String oldToken,String newToken) {
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangeToken::currentStatus: '+currentStatus);
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangeToken::oldToken: '+oldToken);
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangeToken::newToken: '+newToken);
        String changeToken = newToken;
        Set<String> successOptimaxStatusSet = new Set<String> {WSCH_Constants.STATUS_OPT_TENTATIVE,WSCH_Constants.STATUS_OPT_COMPLETED,WSCH_Constants.STATUS_OPT_QUEUED};
        if (!successOptimaxStatusSet.contains(currentStatus)) {
            Integer oldChangeTokenRank = WSCH_Constants.CHANGE_TOKEN_PRIORITY.get(oldToken);
            Integer newChangeTokenRank = WSCH_Constants.CHANGE_TOKEN_PRIORITY.get(newToken);
            //If Priority not found assigning default values.
            oldChangeTokenRank = oldChangeTokenRank == null ? WSCH_Constants.CHANGE_TOKEN_DEFAULT_PRIORITY : oldChangeTokenRank;
            newChangeTokenRank = newChangeTokenRank == null ? WSCH_Constants.CHANGE_TOKEN_DEFAULT_PRIORITY : newChangeTokenRank;
            if(oldChangeTokenRank == Math.min(oldChangeTokenRank,newChangeTokenRank)) {
                changeToken = oldToken;
            }
        }
        return changeToken;
    }

    /**
        Following method validates whether the field match rule engine required to invoke .
     **/    
    public static void doQualifyFieldMatchRuleEngine(map<string, Map<String, String>> svmxSettingList, List<SVMXC__Service_Order__c> workorderList, Boolean isInsert, Boolean isUpdate){
    //public static void doQualifyFieldMatchRuleEngine(Map<String, String> svmxSettingList, List<SVMXC__Service_Order__c> workorderList, Boolean isInsert, Boolean isUpdate){
        //to avoid recursive trigger invoke.
        if(rulesExecuted){
            return;
        }
        
        if( isInsert || isUpdate ){
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQualifyFieldMatchRuleEngine(): Trigger.isBefore isInsert:'+isInsert+' isUpdate :'+isUpdate);
            
            String strRuleSwitch = 'false';
            
            if(svmxSettingList.containsKey('WORD023') && svmxSettingList.get('WORD023') != null && svmxSettingList.get('WORD023').size() > 0)
            {
                map<String, String> mapEachSetting = new map<String, String>();
                mapEachSetting = svmxSettingList.get('WORD023');
                WSCH_AuditLogger.debug('mapEachSetting = ' + mapEachSetting.get('SET001'));
                if(mapEachSetting.containsKey('SET001') && mapEachSetting.get('SET001') != null){
                    strRuleSwitch=mapEachSetting.get('SET001');
                }
            }
            
               
            if(strRuleSwitch.toUpperCase()=='FALSE'){
                WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQualifyFieldMatchRuleEngine(): Field Match Rule Engine not enabled.');
                WSCH_AuditLogger.finish();
                return;
            }
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQualifyFieldMatchRuleEngine(): Field Match Rule Engine enabled');
            //to fetch the rules which source object name is workorder.
            //WSCH_FieldMatchRuleEngine.sourceName='SVMXC__Service_Order__c';
            
            //get the limit from the config setting to use select query.
            //commented the below code of retrieving the limit value from settings.
            //This code has been shifted to FieldMatchRuleEngine class to make the setting value available for the
            //custom trigger requiring DataLookupRule evaluation. This is a fix for the Defect 042837
            /*String strConfigLimit='';
            if(svmxSettingList.containsKey('GLOB001') && svmxSettingList.get('GLOB001') != null && svmxSettingList.get('GLOB001').size() > 0)
            {
                map<String, String> mapEachSetting = new map<String, String>();
                mapEachSetting = svmxSettingList.get('GLOB001');
                system.debug(LoggingLevel.WARN, 'mapEachSetting = ' + mapEachSetting.get('GBL026'));
                if(mapEachSetting.containsKey('GBL026') && mapEachSetting.get('GBL026') != null){
                    strConfigLimit = mapEachSetting.get('GBL026');
                }
            }
            //String strConfigLimit = WSCH_CommonUtils.getSettingValue('GLOB001','GBL026');
            if(strConfigLimit != null && strConfigLimit.length() > 0){
                WSCH_Constants.STR_DEFAULT_LIMIT = strConfigLimit;
            }*/ 
            WSCH_FieldMatchRuleEngine ruleEngine = new WSCH_FieldMatchRuleEngine();
            ruleEngine.processFieldMatchingRules(workorderList);
            rulesExecuted=true;
            WSCH_AuditLogger.finish();
         }
    }
    
    /**  
        This method compares the OldWO's from the map with the new list of WO's for custom fields change and returns the new WO list
    **/
    public static List<SVMXC__Service_Order__c> getChangedWOList(List<SVMXC__Service_Order__c> newWorkOrderList, Map<String, Map<String, Object>> oldWOIdFieldValuesMap) {
        //WSCH_AuditLogger.debug('WSCH_TriggerHandler:getChangedWOList(): before modification newWorkOrderList: ' + newWorkOrderList);
        Boolean isCustomFieldChanged = false;
        String schedulingChangeToken;
        List<SVMXC__Service_Order__c> finalWOList = new List<SVMXC__Service_Order__c>();
        Set<String> oldWoIdSet = oldWOIdFieldValuesMap.keySet();
        Set<String> bookJobCustFieldsSet = getBookJobFieldsFromSettings();
        Set<String> updateJobCustFieldsSet = getUpdateJobFieldsFromSettings();
        
        for(Integer i=0; i<newWorkOrderList.size(); i++) {
            String strNewWOId = newWorkOrderList.get(i).Id;
            SVMXC__Service_Order__c eachWorkOrderObj = newWorkOrderList.get(i);
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangedWOList::Fetched WO Details: New Token - ' + eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c);
            Map<String, Object> woFieldValueMap = oldWOIdFieldValuesMap.get(strNewWOId);
            
                //do the comparison of the custom fields from new and old WO's
                Set<String> strWOFields = woFieldValueMap.keySet();
                WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangedWOList::strWOFields : ' + strWOFields);
                WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangedWOList::bookJobCustFieldsSet : ' + bookJobCustFieldsSet);
                for(String eachWOField : strWOFields) {
                    
                    if(eachWOField != 'SVMXC__OptiMax_Status__c' && eachWOField != 'SVMXC__Scheduling_Change_Token__c' 
                            && eachWOField != 'WOId' && eachWOField != 'PROCESS_FURTHER') {
                        if(woFieldValueMap.get(eachWOField) != eachWorkOrderObj.get(eachWOField)) {
                            //check if the current custom field is a rebookJob custom field
                            if(bookJobCustFieldsSet.contains(eachWOField)) {
                                schedulingChangeToken = 'CHANGE_CUSTOM_FIELDS_BOOK';
                            } else if(updateJobCustFieldsSet.contains(eachWOField)) {
                                schedulingChangeToken = 'CHANGE_CUSTOM_FIELDS_UPDATE';
                            }
                        isCustomFieldChanged = true;
                        }
                    }                               
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangedWOList::isCustomFieldChanged : ' + isCustomFieldChanged);
                    if (isCustomFieldChanged) {
                        eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c = getChangeToken(String.valueOf(woFieldValueMap.get('SVMXC__OptiMax_Status__c')),String.valueOf(woFieldValueMap.get('SVMXC__Scheduling_Change_Token__c')),schedulingChangeToken);
                        WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangedWOList::Scheduling Change Token : ' + eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c);
                    }else if(strNewWOId.equalsIgnoreCase(String.valueOf(eachWorkOrderObj.id)) && 'CHANGE_RESOURCE_PREFERENCE'.equalsIgnoreCase(String.valueOf(woFieldValueMap.get('SVMXC__Scheduling_Change_Token__c')))){
                        eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c = getChangeToken(String.valueOf(woFieldValueMap.get('SVMXC__OptiMax_Status__c')),String.valueOf(woFieldValueMap.get('SVMXC__Scheduling_Change_Token__c')),schedulingChangeToken);
                        eachWorkOrderObj.SVMXC__Scheduling_Retry_Count__c = 0;
                        WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangedWOList::Scheduling Change Token : ' + eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c);
                    }
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangedWOList::woFieldValueMap.get(\'SVMXC__Scheduling_Change_Token__c\') : ' + woFieldValueMap.get('SVMXC__Scheduling_Change_Token__c'));
                    WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangedWOList::eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c : ' + eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c);
                }
                //populate the finalWOList with only those WOs whose oldToken != newToken
                if(woFieldValueMap.get('PROCESS_FURTHER') == true ||  (isCustomFieldChanged)) {
                  finalWOList.add(eachWorkOrderObj);
                }
        }
        WSCH_AuditLogger.debug('WSCH_TriggerHandler::getChangedWOList::finalWOList : ' + finalWOList);
        return finalWOList;
    }
    //This method creates Optimizer Transaction records for each work order, which will be used to Optimize the batching
    public static void createOptTrans(Map<String,String> mapWo){
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = new list<SVMXC__SVMX_Optimizer__c>();
        try{
            if((isSmaxQSettingEnabled != null) && (isSmaxQSettingEnabled)){
                for (String woRec : mapWo.keySet()) {
                    SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
                    optimizer.SVMXC__WhatId__c = woRec;                   
                    optimizer.SVMXC__WhatType__c = 'WORK_ORDER';
                    if(optimizer.SVMXC__WhatType__c != null && optimizer.SVMXC__WhatType__c != '' && optimizer.SVMXC__WhatType__c.equals('WORK_ORDER'))
                        optimizer.SVMXC__SM_Work_Order__c = woRec;
                    optimizer.SVMXC__Optimizer_Change_Token__c = mapWo.get(woRec);
                    optimizer.SVMXC__Optimizer_Status__c = 'BATCH_QUEUED';
                    optimizer.SVMXC__Optimizer_Retry_Count__c = 0;
                    lstSVMXOptimizer.add(optimizer);
                }
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstsvmxoptimizer, COMM_SecurityUtils.Access.Upsertable)){
                    Database.upsert(lstsvmxoptimizer);                                                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
                
                WSCH_AuditLogger.finish();
            }
        }catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_TriggerHandler:createOptTrans() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        
    }
    public static Boolean getSmaxQSetting(){
        String setVal = '';
        Boolean isSmaxQEnabled =false;
        try{
            //setVal = WSCH_CommonUtils.getSettingValue('DCON004','SET00777');
            setVal = WSCH_CommonUtils.getSettingValue('DCON004','SET015');
            if(String.isNotBlank(setVal)){
                isSmaxQEnabled = Boolean.valueOf(setVal);
            }
            WSCH_AuditLogger.debug('WSCH_TriggerHandler: SmaxQSetting ' + isSmaxQEnabled);
        }catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_TriggerHandler:getSmaxQSetting() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return isSmaxQEnabled;
    }

    public static void updateWoOptStatus(SVMXC__Service_Order__c woStatus){
        if((isSmaxQSettingEnabled != null) && (isSmaxQSettingEnabled)){
            if(woStatus.SVMXC__OptiMax_Status__c != WSCH_Constants.STATUS_OPT_BATCH){
                woStatus.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_QUEUED; 
            }
        }
        
    }
    //This method calculates the Scheduling Token Based on the the custom field changed, if the Field is a Formula Field
    public static String isCustomFieldChangeSmaxQ(SVMXC__Service_Order__c oldWoRecord, SVMXC__Service_Order__c newWoRecord, String oldToken){
        String objName = 'SVMXC__Service_Order__c';
        Boolean isFormulaField = false, isFormulaFieldChanged = false;
        //create Set of Custom Book Job, adn Custom Update Job Fields
        Set<String> bookJobCustFieldsSet = getBookJobFieldsFromSettings();
        Set<String> updateJobCustFieldsSet = getUpdateJobFieldsFromSettings();
        String strOldFieldVal, strNewFieldVal, newToken,changeToken;
        List<String> lstWoFormulField = new List<String>();
        //SVMXC__Service_Order__c newWoRecord = new SVMXC__Service_Order__c();
        try{
            changeToken = oldToken;
            //check if the set of Custom Fields is Empty
            if((!bookJobCustFieldsSet.isEmpty()) || (!updateJobCustFieldsSet.isEmpty())){
                if((!setStrCustomFields.isEmpty()) && (!mapOfFields.isEmpty())){
                    for(String key : mapOfFields.keySet())  
                    {
                        if(setStrCustomFields.contains(key.toUpperCase().trim())){
                            Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();
                            //check if the field is a FORMULA field  
                            if((fieldResult.isAccessible()) && (fieldResult.isCalculated())){
                                //check if Custom Update Job
                                if (updateJobCustFieldsSet.contains(fieldResult.getName())){
                                    isFormulaField = true;
                                    lstWoFormulField.add(fieldResult.getName());
                                    newToken = 'CHANGE_CUSTOM_FIELDS_UPDATE';
                                    //check if Custom Book Job
                                }else if(bookJobCustFieldsSet.contains(fieldResult.getName())){
                                    isFormulaField = true;
                                    lstWoFormulField.add(fieldResult.getName());
                                    newToken = 'CHANGE_CUSTOM_FIELDS_BOOK';
                                }
                            }
                        }
                    }
                }
                if(isFormulaField){
                    //newWoRecord = WSCH_CommonUtils.fetchWorkOrderById(oldWoRecord.Id);
                    for(String strField: lstWoFormulField){
                        strOldFieldVal = String.valueOf(oldWoRecord.get(strField));
                        strNewFieldVal = String.valueOf(newWoRecord.get(strField));
                        if((strOldFieldVal != null) && (strNewFieldVal != null) && (strOldFieldVal != strNewFieldVal)){
                            isFormulaFieldChanged = true;
                        }
                    }
                    if(isFormulaFieldChanged){
                        //set change token as Custom Field Change
                        changeToken = newToken;
                        Integer oldChangeTokenRank = WSCH_Constants.CHANGE_TOKEN_PRIORITY.get(oldToken);
                        Integer newChangeTokenRank = WSCH_Constants.CHANGE_TOKEN_PRIORITY.get(newToken);
                        //If Priority not found assigning default values.
                        oldChangeTokenRank = oldChangeTokenRank == null ? WSCH_Constants.CHANGE_TOKEN_DEFAULT_PRIORITY : oldChangeTokenRank;
                        newChangeTokenRank = newChangeTokenRank == null ? WSCH_Constants.CHANGE_TOKEN_DEFAULT_PRIORITY : newChangeTokenRank;
                        if(oldChangeTokenRank == Math.min(oldChangeTokenRank,newChangeTokenRank)) {
                            changeToken = oldToken;
                        }
                    }
                }
            }
        }catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_TriggerHandler:isCustomFieldChangeSmaxQ() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return changeToken;
    }
    public static Set<String> fetchSetJobFields(){
        Set<String> setReturn = new Set<String>();
        if(String.isNotBlank(strBookJobCustomFields)){
            setReturn.addAll(strBookJobCustomFields.toUpperCase().split(',',0));
        }
        if(String.isNotBlank(strUpdateJobCustomFields)){
            setReturn.addAll(strUpdateJobCustomFields.toUpperCase().split(',',0));
        }            
        return setReturn;
    }
    
    /**
     * Name             :   loadDCEventMgmtSettings
     * Params           :   None
     * Returns          :   Map<Key, Values> where Key is a module# 'DCON005' and values are the settings SET001, SET002., etc
     * Description      :   This is to get all the settings under the 'Event Management' submodule of 'Dispatch Management' module
     */
    public static Map<String, String> loadDCEventMgmtSettings()
    { 
        try
        {
            if(lstDCEventMgmtSettings == NULL || lstDCEventMgmtSettings.size() == 0)
            {
                list<String> eventSubModule = new list<string>{'DCON005'};
                SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                lstDCEventMgmtSettings = commSettings.SVMX_getSettingList(eventSubModule);          
            }
        } 
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return lstDCEventMgmtSettings.get('DCON005');
    }
    
    /**
     * Name             :   updateWO
     * Params           :   None
     * Returns          :   list<SVMXC__Service_Order__c>
     * Description      :   This is to update Work Order with 'Minimum Event Duration' defined in the setting SET008
     */
    /* commented for 039581 defect shifting following logic from after insert to before insert 
    public static void updateWO(List<SVMXC__Service_Order__c> lstWOs)
    {
        List<String> workOrderIds = getQualifiedWOIds(lstWOs);
        for(SVMXC__Service_Order__c tempWO : lstWOs)
        {
            workOrderIds.add(tempWO.Id);
        }
        
        if(workOrderIds.size() > 0 )
        { 
            try
            {
                List<SVMXC__Service_Order__c> workOrderList = WSCH_CommonUtils.fetchWorkOrders(workOrderIds);
                //This will be skippend when UT execution, as there were recursive calls which was causing multiple UT failures
                //This should be revisited if needed in later stage
                if(!Test.isRunningTest())
                {
                    Map<String, String> mapDCEventMgmtSettings = new Map<String, String>(loadDCEventMgmtSettings());                
                    list<SVMXC__Service_Order__c> lstWORecords = new list<SVMXC__Service_Order__c>();
                    
                    if(mapDCEventMgmtSettings.containsKey('SET008'))
                    {
                        integer minEventDuration = integer.ValueOf(mapDCEventMgmtSettings.get('SET008'));
                        for(SVMXC__Service_Order__c woRec: workOrderList)
                        {
                            woRec.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = minEventDuration;
                            lstWORecords.add(woRec);
                        }
                        //upsert lstWORecords;
                        // -CRUD
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWORecords,COMM_SecurityUtils.Access.Upsertable))   {
                                upsert lstWORecords;
                            } 
                        else 
                            {
                                throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                            }
                    }
                }
            }
            catch(Exception ex)
            {
                 system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                throw new SVMXException(ex.getMessage());
            }
        }
    }
    */
       
    public static void doQTLwithResourcePreference(Boolean isInsert, Boolean isUpdate){
        
        try{
            WSCH_AuditLogger.debug('WSCH_TriggerHandler::doQTLwithResourcePreference(): Trigger AFTER INSERT:'+isInsert+' Trigger BEFORE UPDATE :'+isUpdate);
            WSCH_AuditLogger.debug('Start of WSCH_TriggerHandler::doQTLwithResourcePreference():No of Queries used in this trigger code so far: ' + Limits.getQueries());
            
            //From the list of input work orders, identify the work orders that qualify for QTL
            List<SVMXC__Service_Order__c> lstQualifiedWOs = new List<SVMXC__Service_Order__c>(OMAX_PreCalculation.mapWorkOrder.values());

            //Considering only those WO which don't have Skill Set already calculated
            //list<SVMXC__Service_Order__c>  lstWorkOrdersForSkillCompute = new list<SVMXC__Service_Order__c>();
            list<SVMXC__Service_Order__c>  lstWorkOrdersForQTLCompute = new list<SVMXC__Service_Order__c>();
            
            if(lstQualifiedWOs != null && lstQualifiedWOs.size() > 0){
                //filtering separate list of workorders which is qualified for QTL
                //QTL workorders criteria is Workorder should be OptiMax DP and Qualified Technicians field is empty.
                //Below skill computation commented and its moved again before insert/update. to avoid explicity wo update for considering PB immediate assignment issue.
                for(SVMXC__Service_Order__c objWO : lstQualifiedWOs){
                    if(isOptiMaxWO(objWO,OMAX_PreCalculation.mapOmaxDispatchProcess) || isOptiMaxECOWO(objWO,OMAX_PreCalculation.mapECODispatchProcess)){
                        if(objWO.SVMXC__Qualified_Technicians__c == null || objWO.SVMXC__Qualified_Technicians__c == ''){
                            lstWorkOrdersForQTLCompute.add(objWO);  
                        }
                    }
                }
                //WSCH_AuditLogger.setLogContext(WSCH_AuditLogger.fetchTeritoryName(teritoryId.split(',')[0]));
                system.debug('List of Workorders qualified for QTL computation...size'+lstWorkOrdersForQTLCompute.size());
                //system.debug('List of Workorders qualified for Skills computation...'+lstWorkOrdersForSkillCompute);
                // Invoke skill and QTL calculation if if GBL007 is True and its only OptiMax Workorders
                if(lstWorkOrdersForQTLCompute != null && lstWorkOrdersForQTLCompute.size() >0){
                    //QTL computation
                    SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch clsQTLComputation = new SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch();
                    map<string, Map<String, String>> mapAllSettings=SVMX_Constants.AllsvmxSettingList;
                    map<Id, SVMXC__ServiceMax_Processes__c> mapAllDispatchProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
                    mapAllDispatchProcess.putAll(OMAX_PreCalculation.mapOmaxDispatchProcess);
                    mapAllDispatchProcess.putAll(OMAX_PreCalculation.mapECODispatchProcess);
                    clsQTLComputation.buildQualifiedTechnicians(lstWorkOrdersForQTLCompute,mapAllSettings,OMAX_PreCalculation.setTerritoryIds,mapAllDispatchProcess);
                
                    //If after insert call then we need to update the QTL list computed
                    if(isInsert){
                        WSCH_OptimizedSchedulingService.triggerExecuted = true;
                        WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                        if(lstWorkOrdersForQTLCompute != null && lstWorkOrdersForQTLCompute.size() > 0) {   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWorkOrdersForQTLCompute, COMM_SecurityUtils.Access.Updateable)){
                                update lstWorkOrdersForQTLCompute;
                            } else {
                                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                            }
                        }
                    }                   
                }          
            }
            //setting the below flag to true after the QTL with Resource Preference is calculated
            WSCH_TriggerHandler.isQTLResourcePrefCalculated = true;
            
            WSCH_AuditLogger.finish();
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_TriggerHandler:doQTLwithResourcePreference() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        System.debug('End of WSCH_TriggerHandler::doQTLwithResourcePreference():No of Queries used in this trigger code so far: ' + Limits.getQueries());
    }
    
    public static boolean isOptiMaxWO(SVMXC__Service_Order__c newWO,map<Id, SVMXC__ServiceMax_Processes__c> mapOptiMaxDP){
        if(newWO != null && newWO.SVMXC__Dispatch_Process__c != NULL){
            if(mapOptiMaxDP.ContainsKey(newWO.SVMXC__Dispatch_Process__c)){
                return true;
            }
        }
        return false;
    }
    
    public static boolean isOptiMaxECOWO(SVMXC__Service_Order__c newWO,map<Id, SVMXC__ServiceMax_Processes__c> mapOptiMaxECODP){
        if(newWO != null && newWO.SVMXC__Dispatch_Process__c != NULL){
            if(mapOptiMaxECODP.ContainsKey(newWO.SVMXC__Dispatch_Process__c)){
                return true;
            }
        }
        return false;
    }       

}