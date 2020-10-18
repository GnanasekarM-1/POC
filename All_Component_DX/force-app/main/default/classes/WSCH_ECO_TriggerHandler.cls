/**
@ Name WSCH_ECO_TriggerHandler
@ Author Anantha Kumar 
@ Description Define future call to schedule workorders. Invokes the OptiMax ECO Rest API call based on the type of change in work order
 */
public with sharing class WSCH_ECO_TriggerHandler {
    
    public class SVMXException extends Exception {}
    public static boolean rulesExecuted = false; 
    public static String strOldWO = 'old workorder values';
    public static String strBookJobCustomFields;
    //public static String strUpdateJobCustomFields;
    
    public static String strScheToken;
    
    public static Map<String,String> mapWoSchToken;
    public static boolean isForceFixSchedDate;
    public static Boolean isSmaxQSettingEnabled = false;
    public static Map<String, Schema.SObjectField> mapOfFields;
    public static Map<String, Schema.SObjectType> gblDesc;
    public static Set<String> setStrCustomFields = new Set<String>();
    public static map<string, Map<String, String>> lstDCEventMgmtSettings = new map<string, Map<String, String>>();
    public static Map<String, String> mapOfTechIdAndTerritoryId = new Map<String, String>();
    public static Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
    public static List<SVMXC__SVMX_Jobs__c> listJob = new List<SVMXC__SVMX_Jobs__c>();
    public static boolean isExternalWO = false;
        
    static {
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::Inside static block');
        isSmaxQSettingEnabled = getSmaxQSetting();
        runSOQL();
    }
    
    public static void runSOQL() {
        svmxProcessMap = WSCH_CommonUtils.getEcoDP();
        listJob = [SELECT Id, SVMXC__SVMX_Process__c, SVMXC__Territory__c, SVMXC__OptiMax_Message__c from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :svmxProcessMap.keySet()];
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::runSOQL():listJob.size() - ' + listJob.size());
    }

   /** Method to identify OptiMax ECO Rest API and Optimize based on the work order field changes **/
    
    public static void doQualifyWorkorderEco(List<SVMXC__Service_Order__c> workorderList){
        try{
            
            WSCH_AuditLogger.debug('Start of WSCH_ECO_TriggerHandler::doQualifyWorkorderEco():No of Queries used in this trigger code so far: ' + Limits.getQueries());
            //get the qualified workorder ids.

            List<String> qualifiedWOIds = getEcoWOIds(workorderList);
            mapWoSchToken = new Map<String,String>();

            if(qualifiedWOIds.size() > 0){
                //Call the Abstraction Service to Schedule the WorkOrders.
                if(System.isBatch() || System.isFuture()) {
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::doQualifyWorkorderEco()::Source is a FutureCall/Batch, So mark the workOrder for Batch execution :'+qualifiedWOIds);
                    updateWorkOrders(qualifiedWOIds, WSCH_ECO_Constants.STATUS_OPT_BATCH, 'CHANGE_CREATE_WO');
                    WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.WO_BATCH_CLASS_NAME, WSCH_Constants.BATCH_APEX_START_TIME);
                } else {
                    updateWorkOrders(qualifiedWOIds, WSCH_ECO_Constants.STATUS_OPT_PENDING, 'CHANGE_CREATE_WO');
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::doQualifyWorkorderEco():Before calling manageWorkOrders API (future call)...');
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::doQualifyWorkorderEco():Number of Queries used in this apex code so far: ' + Limits.getQueries());
                    //Save the Audit Logger to the SVMX JOb Logs
                    
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
                system.debug('****WSCH_ECO_TriggerHandler doQualifyWorkorderEco  Calling Finish '+System.isFuture());
            }            
        }catch(Exception ex){
            
        }
    }


    public static void updateWorkOrders(List<String> workOrderIds, String status, String changeType) {
        //WSCH_AuditLogger.rca('Updating the following Workorders : '+workOrderIds+' ; SVMXC__Scheduling_Change_Token__c :'+changeType+' and SVMXC__OptiMax_Status__c : '+status);
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
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:workOrderList:strSetOfUpdateableFields: ' + WSCH_CommonUtils.strSetOfUpdateableFields);
        }
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
        
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(workOrderList, COMM_SecurityUtils.Access.Updateable)){    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            update workOrderList;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
    }

    @future(callout=true)
    //public static void manageWorkOrders(List<String> workOrderIdList, Set<String> setWOwithMultiEvnts){
    public static void manageWorkOrders(List<String> workOrderIds){         
        String logContext = '';
        try{
            List<SVMXC__Service_Order__c> workOrderList = WSCH_ECO_CommonUtils.fetchWorkOrders(workOrderIds);
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:manageWorkOrders(): workOrderList size ' + workOrderList.size());
            List<SVMXC__Service_Order__c> manageDependencyWorkOrderList = new List<SVMXC__Service_Order__c>();
            List<SVMXC__Service_Order__c> manageWorkOrderList = new List<SVMXC__Service_Order__c>();
            Set<SVMXC__Service_Order__c> setOfInvalidDependencyWOs = new Set<SVMXC__Service_Order__c>();
            
            for(SVMXC__Service_Order__c eachWO : workOrderList) {
                if((logContext.length() + 11) < 255) {
                    logContext = logContext + eachWO.Name + ', ';
                    WSCH_AuditLogger.setLogContext(logContext);
                }
                //For book dependency group API call
                if(eachWO.SVMXC__Scheduling_Change_Token__c == 'CREATE_DEPENDENCY_WO' || eachWO.SVMXC__Scheduling_Change_Token__c == 'CHANGE_DEPENDENCY_WO'){
                    manageDependencyWorkOrderList.add(eachWO);
                }else{  
                    manageWorkOrderList.add(eachWO);
                }
            }
            system.debug('WSCH_ECO_TriggerHandler::manageWorkOrders:: WOs qualified for dependency Group:'+manageDependencyWorkOrderList);
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::manageWorkOrders:: WOs qualified for dependency Group:'+manageDependencyWorkOrderList);
            if(manageDependencyWorkOrderList != null && manageDependencyWorkOrderList.size() > 0){
                Set<Id> dependencyManagementId = new Set<Id>();
                List<SVMXC__Service_Order_Dependency__c> dependencyGroupList = new List<SVMXC__Service_Order_Dependency__c>();
                //List<Id> groupDependencyId = new List<Id>();
                for(SVMXC__Service_Order__c dependencyWO: manageDependencyWorkOrderList){
                    dependencyManagementId.add(dependencyWO.SVMXC__Dependency_Group__c);
                }
                
                /** ECO Dependency code - start  **/
                //fetch all the dependency objects for all the groupIds received above
                Map<Id, SVMXC__Service_Order__c> mapOfWOIdWorkOrder = new Map<Id, SVMXC__Service_Order__c>();
                List<SVMXC__Service_Order_Dependency__c> lstOfFilteredDependencyObj = new List<SVMXC__Service_Order_Dependency__c>();
                Set<SVMXC__Service_Order__c> setOfFilteredDependencyWOs = new Set<SVMXC__Service_Order__c>();
                
                if(dependencyManagementId.size() > 0){
                    for(Id depGroupId : dependencyManagementId){
                        dependencyGroupList.addAll(WSCH_CommonUtils.fetchGroupDependency(depGroupId));
                    }
                }
                //fetch all the WO Ids from the dependency objects
                Set<String> WO_Ids = new Set<String>();
                if(dependencyGroupList.size() > 0) {
                    for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: dependencyGroupList){
                        WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Primary_Work_Order__c));
                        WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Secondary_Work_Order__c));
                    }
                }
                //fetch all the WOs from the primary and secondary WO Ids fetched above
                List<String> lstOfWOIds = new List<String>(WO_Ids);
                List<SVMXC__Service_Order__c> woList = WSCH_CommonUtils.fetchWorkOrders(lstOfWOIds);
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: manageWorkOrders(): dependencyGroupList.size() - ' + dependencyGroupList.size());
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: manageWorkOrders(): woList.size() - ' + woList.size());
                //create a map of WOid and WO which is used below to create a filtered list of DependencyObj and DependencyWOs
                for(SVMXC__Service_Order__c eachWO: woList) {
                    mapOfWOIdWorkOrder.put(eachWO.Id, eachWO);
                }
                //Create a filtered list of dependencyObj and dependencyWOs if they have RTO DP only.
                if(dependencyGroupList.size() > 0) {
                    for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: dependencyGroupList){
                        SVMXC__Service_Order__c primaryWO = mapOfWOIdWorkOrder.get(groupDependencyRecords.SVMXC__Primary_Work_Order__c);
                        SVMXC__Service_Order__c secondaryWO = mapOfWOIdWorkOrder.get(groupDependencyRecords.SVMXC__Secondary_Work_Order__c);
                        
                        if(primaryWO.SVMXC__Dispatch_Process__c == null || !svmxProcessMap.ContainsKey(primaryWO.SVMXC__Dispatch_Process__c)) {
                            secondaryWO.SVMXC__OptiMax_Error_Text__c = 'The dependent Work Order ' + primaryWO.Name +' does not have a valid RTO DP. Hence dependency call cannot be made.';
                            //secondaryWO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                            if(!setOfInvalidDependencyWOs.contains(secondaryWO)) {
                                setOfInvalidDependencyWOs.add(secondaryWO);
                            }
                        }
                        if(secondaryWO.SVMXC__Dispatch_Process__c == null || !svmxProcessMap.ContainsKey(secondaryWO.SVMXC__Dispatch_Process__c)) {
                            primaryWO.SVMXC__OptiMax_Error_Text__c = 'The dependent Work Order ' + secondaryWO.Name +' does not have a valid RTO DP. Hence dependency call cannot be made.';
                            //primaryWO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                            if(!setOfInvalidDependencyWOs.contains(primaryWO)) {
                                setOfInvalidDependencyWOs.add(primaryWO);
                            }
                        }
                        //if both primary and secondary WOs has a valid RTO DP only then add this DependencyObject to the filtered list
                        if(svmxProcessMap.ContainsKey(primaryWO.SVMXC__Dispatch_Process__c) &&
                                svmxProcessMap.ContainsKey(secondaryWO.SVMXC__Dispatch_Process__c)) {
                            lstOfFilteredDependencyObj.add(groupDependencyRecords);
                            //also add the primary and secondary WOs to the new filtered listOfDepWOs
                            setOfFilteredDependencyWOs.add(primaryWO);
                            setOfFilteredDependencyWOs.add(secondaryWO);
                        }
                    }
                }
                //add the above setOfFilteredDependencyWOs into the list below
                List<SVMXC__Service_Order__c> lstOfFilteredDependencyWOs = new List<SVMXC__Service_Order__c>();
                if(setOfFilteredDependencyWOs.size() > 0) {
                    lstOfFilteredDependencyWOs.addAll(setOfFilteredDependencyWOs);
                }

                if(setOfInvalidDependencyWOs.size() > 0) {
                    List<SVMXC__Service_Order__c> lstWOsToUpdate = new List<SVMXC__Service_Order__c>(setOfInvalidDependencyWOs);
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstWOsToUpdate, COMM_SecurityUtils.Access.Updateable) ) {       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update lstWOsToUpdate;
                    }else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return;
                    }
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: manageWorkOrders:Updated the invalid WOs with the error message');
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: manageWorkOrders:lstWOsToUpdate.size() - ' + lstWOsToUpdate.size());
                }

                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: manageWorkOrders(): lstOfFilteredDependencyObj.size() - ' + lstOfFilteredDependencyObj.size());
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: manageWorkOrders(): lstOfFilteredDependencyWOs.size() - ' + lstOfFilteredDependencyWOs.size());
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: manageWorkOrders(): Before making manageDependencyBooking() call');
                
                if(lstOfFilteredDependencyObj.size() > 0 && lstOfFilteredDependencyWOs.size() > 0) {
                    WSCH_OptimizedSchedulingService.triggerExecuted = true;
                    WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                    WSCH_OptimizedSchedulingService.manageDependencyBooking(lstOfFilteredDependencyObj, lstOfFilteredDependencyWOs);
                } else {
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: manageWorkOrders(): dependency call cannot be made as there are no valid dependency objects');
                    WSCH_AuditLogger.finish();
                }
                /** ECO Dependency code - end  **/
            }
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::manageWorkOrders:: WOs qualified for normal UpdateJob call:'+manageWorkOrderList); 
             
            if(manageWorkOrderList.size() > 0){
                WSCH_OptimizedSchedulingService.manageWorkOrders(manageWorkOrderList);
            }
        }catch(Exception ex){
            system.debug('Exception caught:WSCH_ECO_TriggerHandler:manageWorkOrders() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_TriggerHandler:manageWorkOrders() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }

    /** Method to identify SP API and Optimize based on the work order field changes **/
    public static void identifyAPIAndOptimizeEco(List<SVMXC__Service_Order__c> newWoList,List<SVMXC__Service_Order__c> oldWoList) {
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco():Entering into update qualification logic..');
        WSCH_AuditLogger.debug('Start of WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco():No of Queries used in this trigger code so far: ' + Limits.getQueries());
        //get the type of source call 
        boolean isFutureContext = System.isBatch() || System.isFuture();
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::isFutureContext: ' + isFutureContext + ' , System.isBatch(): '+System.isBatch() + ' , System.isFuture() : '+System.isFuture());
        mapWoSchToken = new Map<String,String>();
        String logContext = '';
        Set<SVMXC__Service_Order__c> updatedWoSet = new Set<SVMXC__Service_Order__c>();
        Set<String> ecoWOsSet = new Set<String>();
        Set<String> allowedSchedulingStatus = new Set<String> {'Tentative','Dispatched'};       
        List<String> lstOfTechIds = new List<String>();
        
        //Begin: supporting logic to handle external WOs
        //fetch all the WO technicians and create a map of Technician and their territory
        for(Integer i = 0; i < newWoList.size(); i++) {
            if(newWoList.get(i).SVMXC__Group_Member__c != null) {
                lstOfTechIds.add(newWoList.get(i).SVMXC__Group_Member__c);
            }
        }
        
        Map<Id,SVMXC__Service_Group_Members__c> mapOfTechidAndTechObj;
        if(lstOfTechIds.size() > 0) {
            mapOfTechidAndTechObj = WSCH_ECO_CommonUtils.getTechnicians(lstOfTechIds);
            //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::mapOfTechidAndTechObj.size():' + mapOfTechidAndTechObj.size());
            if(mapOfTechidAndTechObj != null && mapOfTechidAndTechObj.size() > 0) {
                for(String eachTechId : mapOfTechidAndTechObj.keySet()) {
                    mapOfTechIdAndTerritoryId.put(eachTechId, mapOfTechidAndTechObj.get(eachTechId).SVMXC__Service_Territory__c);
                }
            }
            //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::mapOfTechIdAndTerritoryId.size():' + mapOfTechIdAndTerritoryId.size());
        }
        //End
        
        //Multi-resource and Multi-appointment
        List<String> listECOWOIdswithLockByDCTrue = new List<String>();
        Map<String, String> mapfTerrfWOId = new Map<String, String>();
        List<SVMXC__Service_Order__c> listWOsLockByDCTrueToFalse = new List<SVMXC__Service_Order__c>();
        Boolean isWOTerritoryORTechChanged = false;

        for(Integer i = 0; i < newWoList.size(); i++){    
            SVMXC__Service_Order__c newWO = newWoList[i];
            SVMXC__Service_Order__c oldWO = oldWoList[i];

            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::Old WorkOrder Schedule :'+oldWO.SVMXC__Scheduled_Date_Time__c+'| OldWO.Duration :'+oldWO.SVMXC__Service_Duration__c+'| OldWO.LockedByDC :'+oldWO.SVMXC__Locked_By_DC__c+'| OldWO.Technician :'+oldWO.SVMXC__Group_Member__c+'| OldWO.Dispatch Status :'+oldWO.SVMXC__Dispatch_Status__c+'| OldWO.SVMXC__NoOfTimesScheduled__c :'+oldWO.SVMXC__NoOfTimesScheduled__c+'| OldWO.SVMXC__NoOfTimesAssigned__c :'+oldWO.SVMXC__NoOfTimesAssigned__c+'| OldWO.Lock Appointment Sch :'+oldWO.SVMXC__SM_Lock_Appointment_Schedule__c+'| OldWO.SVMXC__Last_Dispatch_Event__c :'+OldWO.SVMXC__Last_Dispatch_Event__c);
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::New WorkOrder Schedule :'+newWO.SVMXC__Scheduled_Date_Time__c+'| NewWO.Duration :'+newWO.SVMXC__Service_Duration__c+'| NewWO.LockedByDC :'+newWO.SVMXC__Locked_By_DC__c+'| NewWO.Technician :'+newWO.SVMXC__Group_Member__c+'| NewWO.Dispatch Status :'+newWO.SVMXC__Dispatch_Status__c+'| NewWO.SVMXC__NoOfTimesScheduled__c :'+newWO.SVMXC__NoOfTimesScheduled__c   +'| NewWO.SVMXC__NoOfTimesAssigned__c :'+newWO.SVMXC__NoOfTimesAssigned__c+'| NewWO.Lock Appointment Sch :'+newWO.SVMXC__SM_Lock_Appointment_Schedule__c+'| newWO.SVMXC__Last_Dispatch_Event__c :'+newWO.SVMXC__Last_Dispatch_Event__c+'| UnAssignDC flag :'+WSCH_OptimizedSchedulingService.isUnAssignDC);

            //resetting the optimx status to null, when we assigned the technician to the un assigned work order (optimax status is  'OPT_UNASSIGNED') through DC.
            if(('Assigned'.equalsIgnoreCase(newWO.SVMXC__Last_Dispatch_Event__c) || 'Scheduled'.equalsIgnoreCase(newWO.SVMXC__Last_Dispatch_Event__c)) && 'OPT_UNASSIGNED'.equalsIgnoreCase(newWO.SVMXC__OptiMax_Status__c)){
                newWO.SVMXC__OptiMax_Status__c=null;
            }
            
           //Checking if this workorder is qualifying for Book Job,Book Appointment and Dependency Job.
            if((newWO.SVMXC__Schedule_As_A_Dependent_Work_Order__c && newWO.SVMXC__Dependency_Group__c == null)){
                continue;
            }
            if(WSCH_DependencyTriggerHandler.getDependencySetting() == false && newWO.SVMXC__Dependency_Group__c != null){
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco: Manage Dependency Setting is disabled. But the work order belongs to dependency group. so skip the work order.');
                continue;
            }            

            //to avoid recursive update calls.
            if('CHANGE_CREATE_WO'.equalsIgnoreCase(oldWO.SVMXC__Scheduling_Change_Token__c) && 'OPT_PENDING'.equalsIgnoreCase(oldWO.SVMXC__OptiMax_Status__c)){
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::already one future call is pending so skip this update...');
                continue;
            }

            //Below code commented as we enabled to cancel/update the dispatched work orders. 20.2 release
            //If the work order scheduling status should be tentative or dispatched than allow else continue to next work order. dispatched wos started processing from 20.2
            if(newWO.SVMXC__Work_Order_Scheduling_Status__c != null && !allowedSchedulingStatus.contains(newWO.SVMXC__Work_Order_Scheduling_Status__c)){
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::Work order scheduling status is not tentative or dispatched. so skip this update');
                continue;
            }
            
            //if the work order is NOT a BookJob,BookAppointment, DependencyGroup work order and external wo, then continue to next work order.
            isExternalWO = getIsExternalWO(newWO, oldWO, svmxProcessMap);
            if (!(isBookJobWO(newWO, svmxProcessMap) || isAppointmentWO(newWO) || (isDependencyJobWO(newWO, svmxProcessMap)) || isExternalWO )) {
                continue;
            }

            // //Check if the order status is canceled. If canceled , no update calls made to SP.
            // if('Canceled'.equalsIgnoreCase(oldWO.SVMXC__Order_Status__c)) {
            //     continue;
            // }

            if(isExternalWO && 'Assigned'.equalsIgnoreCase(oldWO.SVMXC__Last_Dispatch_Event__c) && 'Scheduled'.equalsIgnoreCase(newWO.SVMXC__Last_Dispatch_Event__c) && WSCH_OptimizedSchedulingService.isUnAssignDC){
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::Update scheduled datetime for different territory technician, so skip work order callout.');
                continue;
            }

            if(isExternalWO && 'UnAssigned'.equalsIgnoreCase(oldWO.SVMXC__Last_Dispatch_Event__c) && 'Assigned'.equalsIgnoreCase(newWO.SVMXC__Last_Dispatch_Event__c) && WSCH_OptimizedSchedulingService.isUnAssignDC && NewWO.SVMXC__NoOfTimesScheduled__c == null){
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::Assigned different territory technician, so invoke cancel this work order from existing territory..');
                isWOTerritoryORTechChanged = true;
            }
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco(): isWOTerritoryORTechChanged ' + isWOTerritoryORTechChanged);
            //adding eco qualified workorder to this set
            //ecoWOsSet.add(newWO.id); 
             
            //updating the audit logger object's context field with the current WO name
            if((logContext.length() + 11) < 255) {
                logContext = logContext + oldWO.Name + ', ';
                WSCH_AuditLogger.setLogContext(logContext);
            }
           
           //Check the job qualify for force fixing.
           isForceFixSchedDate = false;
            if(isWOTerritoryORTechChanged){
                newWO.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CANCEL_WO';
                if((newWO.SVMXC__OptiMax_Status__c != WSCH_ECO_Constants.STATUS_OPT_BATCH) && ((isSmaxQSettingEnabled != null) && (isSmaxQSettingEnabled))){
                    mapWoSchToken.put(newWO.id, newWO.SVMXC__Scheduling_Change_Token__c);         
                }
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::WorkOrder: '+newWO.Id+' Qualified for : '+newWO.SVMXC__Scheduling_Change_Token__c);
                updatedWoSet.add(newWO);
                newWO.SVMXC__OptiMax_Status__c = isFutureContext? WSCH_ECO_Constants.STATUS_OPT_BATCH : WSCH_ECO_Constants.STATUS_OPT_PENDING;
                updateWoOptStatus(newWO);
                newWO.SVMXC__Scheduling_Retry_Count__c = 0;
            }
            else if(isFixWO(newWO,oldWO) || isExternalWO && (newWO.SVMXC__Locked_By_DC__c == true || oldWO.SVMXC__Group_Member__c != newWO.SVMXC__Group_Member__c
                                                || oldWO.SVMXC__Primary_Territory__c != newWO.SVMXC__Primary_Territory__c)) {
                //Multi-resource and Multi-appointment - commented out the below code as the piller creation logic for both workorder events and non worokorder events is handled in the Event trigger (WSCH_ECO_EventTriggerHandler.cls)
                //If the Lock By DC is changed from false to true   
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco():: If isFixWO is true ');
                //During Multiassignment through DC, assign work order with different time in same technician.
                //skip this update. 
                if(oldWO.SVMXC__Scheduling_Change_Token__c != 'CHANGE_JOB_FIXED'){
                    newWO.SVMXC__Scheduling_Change_Token__c = getChangeToken(oldWO.SVMXC__OptiMax_Status__c,oldWO.SVMXC__Scheduling_Change_Token__c,'CHANGE_JOB_FIXED');
                    if(newWO.SVMXC__SM_Lock_Appointment_Schedule__c == null && oldWo.SVMXC__SM_Lock_Appointment_Schedule__c == null)
                        newWO.SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
                    listECOWOIdswithLockByDCTrue.add(newWO.Id); 
                }
                continue;
            } else {
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco():: Else '); 
                if(markChangeToken(newWO, oldWO, svmxProcessMap)){
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::WorkOrder: '+newWO.Id+' Qualified for : '+newWO.SVMXC__Scheduling_Change_Token__c);
                    updatedWoSet.add(newWO);
                    newWO.SVMXC__OptiMax_Status__c = isFutureContext? WSCH_ECO_Constants.STATUS_OPT_BATCH : WSCH_ECO_Constants.STATUS_OPT_PENDING;
                    updateWoOptStatus(newWO);
                    newWO.SVMXC__Scheduling_Retry_Count__c = 0;
                    if(newWO.SVMXC__Scheduling_Change_Token__c == 'CHANGE_JOB_UNFIXED'){
                        listWOsLockByDCTrueToFalse.add(newWO);
                    }   
               }
            }
        }
        
        //Multi-resource and Multi-appointment
        //Handle the scenario when a workorder locked by DC made from true to false manually.
        Boolean isMultiEventWO = false;
        Set<String> setWOwithMultiEvnts = new Set<String>();
        if(listWOsLockByDCTrueToFalse != null && listWOsLockByDCTrueToFalse.size() > 0){
            setWOwithMultiEvnts = lockedByDCTrueToFalse(listWOsLockByDCTrueToFalse);
        }
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco():: setWOwithMultiEvnts : '+setWOwithMultiEvnts);
        //Multi-resource and Multi-appointment
        //Handle the scenario when a workorder with single event changed the locked by DC made from false to true manually.
        if(listECOWOIdswithLockByDCTrue != null && listECOWOIdswithLockByDCTrue.size() > 0){
            //Create the optizer records and make a pillar callout 
            WSCH_ECO_EventTriggerHandler.createPillar(listECOWOIdswithLockByDCTrue);
        }
        
        //To delete workorder related events if the token is "CHANGE_CANCEL_WO"
        if(updatedWoSet.size() > 0 && !(isWOTerritoryORTechChanged)){
            WSCH_CommonUtils.deleteWORelatedEventsOnCancel(updatedWoSet);   
        }        
        List<string> workOrderIds = new list<string>();
        if(updatedWoSet.size() > 0 ){
            for(SVMXC__Service_Order__c wo :updatedWoSet){
                if(setWOwithMultiEvnts != null && !setWOwithMultiEvnts.contains(String.valueOf(wo.Id))){
                    workOrderIds.add(String.valueOf(wo.Id));
                }                
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco():: workOrderIds : '+workOrderIds);
        //updatedWoSet      --> Set of eco workorders which is having packaged fields changes and its corresponding token.
        //ecoWOsSet        --> Set of eco workorder Ids only.
        //lstOfCustomFields --> List of custome fields from the Settings(to invoke BookJob and UpdateJob Api calls)

        if(workOrderIds.size() > 0)
        {
            //check source call is future or batch and to avoid further future call.
            if(isFutureContext ) {
                //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco()::Source is a FutureCall/Batch, So mark the workOrder for Batch execution : serializedWOInfo '+serializedWOInfo);
                WSCH_BA_ScheduleHandler.startBatchApex(WSCH_Constants.WO_BATCH_CLASS_NAME, WSCH_Constants.BATCH_APEX_START_TIME);
            } else {
                //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::identifyAPIAndOptimize()::invoke future call with serializedWOInfo '+serializedWOInfo);
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
                                //schedToken = isCustomFieldChangeSmaxQ(oldWoRec, newWoRec, schedToken);
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
                    //manageWorkOrders(serializedWOInfo, setWOwithMultiEvnts);
                    manageWorkOrders(workOrderIds);
                }
            }
        }
        WSCH_AuditLogger.debug('End of WSCH_ECO_TriggerHandler::identifyAPIAndOptimizeEco():No of Queries used in this trigger code so far: ' + Limits.getQueries());   
        WSCH_AuditLogger.finish();
    }   

    public static boolean isFixWO(SVMXC__Service_Order__c newWO, SVMXC__Service_Order__c oldWO) {
        Boolean forceFix=false;
        Set<String> allowedSchedulingStatus = new Set<String> {'Tentative','Fixed'};

        //Based on the DC behaviour the following logic implemented.
        //The following is the sequence.
        //1. Un Assigning existing technician
        //2. Assigning new technician
        //3. Updating Schedule Date Time.
        //So check the schedule datetime instead of checking technician changes in wo
        
        //DC move job with different technician - 3rd update - forceFix set to 'True'
        //DC move job with same technician - forceFix set to 'True'
        
        //System.debug('1-->'+oldWO.SVMXC__Scheduled_Date_Time__c+'2-->'+newWO.SVMXC__Scheduled_Date_Time__c+'3-->'+newWO.SVMXC__Driving_Time__c+'4-->'+oldWO.SVMXC__Scheduled_Date_Time__c);
        if('Scheduled'.equalsIgnoreCase(newWO.SVMXC__Last_Dispatch_Event__c) && (OldWO.SVMXC__Last_Dispatch_Event__c == null || 'Scheduled'.equalsIgnoreCase(OldWO.SVMXC__Last_Dispatch_Event__c))){
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::isFixWO():: scheduled datetime changed and no assignment change');
            forceFix = true;
        }
        
        if(newWO.SVMXC__Locked_By_DC__c == true)
        {
            //SFM scenario - forceFix set to 'True'
            if(newWO.SVMXC__Locked_By_DC__c != oldWO.SVMXC__Locked_By_DC__c)
                forceFix = true;
            
            //DC move job with different technician - 2nd update - skip
            if(newWO.SVMXC__Group_Member__c != oldWO.SVMXC__Group_Member__c && oldWO.SVMXC__Group_Member__c != null)
                forceFix=false;
        }
        
        //Locking in place - logic
        if(newWO.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE && newWO.SVMXC__SM_Lock_Appointment_Schedule__c != oldWO.SVMXC__SM_Lock_Appointment_Schedule__c){
            forceFix = true;
        }else if(newWO.SVMXC__SM_Lock_Appointment_Schedule__c == null && newWO.SVMXC__SM_Lock_Appointment_Schedule__c != oldWO.SVMXC__SM_Lock_Appointment_Schedule__c){
            forceFix = false;
        }
                
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::isFixWO():: ' + forceFix);
        return forceFix;
    }    

    public static boolean markChangeToken (SVMXC__Service_Order__c newWO, SVMXC__Service_Order__c oldWO, Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap) {

        Boolean isQualifyAndMark = false;
        Boolean isCancelledWO = false;
        Boolean isValidDP = false;
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::markChangeToken(): isExternalWO - '+isExternalWO);
        //Boolean isExternalWO = getIsExternalWO(newWO, oldWO, svmxProcessMap);
        Set<Id> setWoIds = new Set<Id>();
        //Set of Scheduling Statuses from which ForceFix call should be allowed.
        Set<String> setWODispStatus = new Set<String>(WSCH_ECO_Constants.WO_SMax_DISPATCH_STATUS);
        setWoIds.add(newWO.id);
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
           (oldWo.SVMXC__OptiMax_Status__c == WSCH_ECO_Constants.STATUS_OPT_COMPLETED)){
               isCancelledWO = true;
               WSCH_AuditLogger.debug('Cancelled WO: ' + newWO.Name);
           }
        //check if the new work order has a valid Linx for SP Dispatch Process
        if(newWO.SVMXC__Dispatch_Process__c != null){
            if(svmxProcessMap.ContainsKey(newWO.SVMXC__Dispatch_Process__c)) {
                isValidDP = true;
            }
        }
        
        Decimal oldlatitude = null;
        Decimal oldlongitude = null;
        Decimal newlatitude = null;
        Decimal newlongitude = null;
        //round an arbitrary Decimal to 3 decimal for compare
        if(oldWO.SVMXC__Latitude__c != null)
            oldlatitude = oldWO.SVMXC__Latitude__c.setScale(3);
        
        if(newWO.SVMXC__Latitude__c != null)
            newlatitude = newWO.SVMXC__Latitude__c.setScale(3);

        if(oldWO.SVMXC__Longitude__c != null)
            oldlongitude =oldWO.SVMXC__Longitude__c.setScale(3);
        
        if(newWO.SVMXC__Longitude__c != null)
            newlongitude = newWO.SVMXC__Longitude__c.setScale(3);
         
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::markChangeToken()::oldlatitude: '+oldlatitude+';newlatitude: '+newlatitude+';oldlongitude :'+oldlongitude+';newlongitude :'+newlongitude);
                        
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
        } else if(oldWo.SVMXC__Group_Member__c != null && newWo.SVMXC__Group_Member__c == null && !WSCH_OptimizedSchedulingService.isUnAssignDC){
            if('CHANGE_JOB_FIXED'.equalsIgnoreCase(oldWO.SVMXC__Scheduling_Change_Token__c)){
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::markChangeToken():Un assigned force fix work order, so clear the fields and stop callout.');
                newWo.SVMXC__Scheduling_Change_Token__c = null;
                newWO.SVMXC__Work_Order_Scheduling_Status__c = null;
                newWO.SVMXC__OptiMax_Status__c=null;
                newWO.SVMXC__Locked_By_DC__c = false;
                newWO.SVMXC__OptiMax_Error_Text__c=null;
                newWO.SVMXC__SM_Lock_Appointment_Schedule__c=null;
             }else{
                schedulingChangeToken = 'CHANGE_CANCEL_WO';
                isQualifyAndMark = true;    
             }
        } else if((oldWo.SVMXC__Dependency_Group__c != newWo.SVMXC__Dependency_Group__c && newWo.SVMXC__Dependency_Group__c == null) && !newWo.SVMXC__Schedule_As_A_Dependent_Work_Order__c) {
            schedulingChangeToken = 'CHANGE_CANCEL_WO';
            isQualifyAndMark = true;

        //When update the status as completed. need to invoke manageWorkOrders API with operation type 'remove' for this token.
        //Remove work order from the run and not remove the event in client side.
        } else if(oldWo.SVMXC__Work_Order_Scheduling_Status__c != newWO.SVMXC__Work_Order_Scheduling_Status__c && newWO.SVMXC__Work_Order_Scheduling_Status__c == 'Completed' ){
            schedulingChangeToken = 'CHANGE_COMPLETED_STATUS';
            isQualifyAndMark = true;
        /* 
            Only allowed to be lock down the schedule when job is not fixed and It should be assigned and Appointment type should be there and picklist value set to 'Lock to arrival window'
        */
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c =='Assigned' && newWO.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_TO_ARRIVALWINDOW && newWO.SVMXC__SM_Lock_Appointment_Schedule__c != oldWo.SVMXC__SM_Lock_Appointment_Schedule__c){ 
            schedulingChangeToken = 'CHANGE_SCHEDULE_LOCK';
            isQualifyAndMark = true;
        /* 
            Only allowed to be rebooked when job is not fixed.
            Qualification logic for Rebook changes : 'CHANGE_CREATE_WO' ,'CHANGE_ZIP_CODE' , 'CHANGE_SKILL_SET' , 'CHANGE_SERVICE_DURATION' ,
            'CHANGE_PREFERRED_TECH' , 'CHANGE_ACCESS_HOURS' , 'CHANGE_START_TIME' , 'CHANGE_END_TIME' , 'CHANGE_DISPATCH_PROCESS'
        */
        /* added the below condition to trigger the update callout for the unassigned WOs  */
        // OPT_ERROR work orders (zip, service duration...not set first time and later update the value. need to be consider for the callout)
        } else if(newWO.SVMXC__Scheduling_Change_Token__c != null && 'CHANGE_CREATE_WO'.equalsIgnoreCase(newWO.SVMXC__Scheduling_Change_Token__c) &&  newWO.SVMXC__Dispatch_Status__c =='New' && newWO.SVMXC__OptiMax_Status__c == WSCH_ECO_Constants.STATUS_OPT_ERROR) { 
            schedulingChangeToken = 'CHANGE_CREATE_WO';
            isQualifyAndMark = true;        
        } else if(newWO.SVMXC__Scheduling_Change_Token__c != null && newWO.SVMXC__OptiMax_Status__c == WSCH_ECO_Constants.STATUS_OPT_UNASSIGNED) {
            schedulingChangeToken = 'CHANGE_CREATE_WO';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c =='New' && newWO.SVMXC__Scheduling_Change_Token__c == null && newWO.SVMXC__Appointment_Promised_Time_Slot__c == null){ //Dispatch Status is New then create wo
            schedulingChangeToken = 'CHANGE_CREATE_WO';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c =='New' && newWO.SVMXC__Scheduling_Change_Token__c != null && newWO.SVMXC__Appointment_Promised_Time_Slot__c == null 
                    && (newWO.SVMXC__Preferred_Start_Time__c != oldWo.SVMXC__Preferred_Start_Time__c || newWO.SVMXC__Preferred_End_Time__c != oldWo.SVMXC__Preferred_End_Time__c)){ //This is the condition when the WO is already OPT_SKIPPED and then PST or PET is updated later.
            schedulingChangeToken = 'CHANGE_CREATE_WO';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c !='New' && newWO.SVMXC__Zip__c != oldWo.SVMXC__Zip__c){
            schedulingChangeToken = 'CHANGE_ZIP_CODE';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c !='New' && ((newlatitude != oldlatitude) || (newlongitude != oldlongitude))){
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::markChangeToken::enter into change lat long condition ');
            schedulingChangeToken = 'CHANGE_LAT_LONG';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c !='New' && newWO.SVMXC__Skill_Set__c != oldWo.SVMXC__Skill_Set__c){
            schedulingChangeToken = 'CHANGE_SKILL_SET';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c !='New' && newWO.SVMXC__Qualified_Technicians__c != oldWo.SVMXC__Qualified_Technicians__c){
            schedulingChangeToken = 'CHANGE_QUALIFIED_TECHNICIAN';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c !='New' && newWO.SVMXC__Service_Duration__c != oldWo.SVMXC__Service_Duration__c){
            schedulingChangeToken = 'CHANGE_SERVICE_DURATION';
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::markChangeToken::enter into change service duration condition ');
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c !='New' && newWO.SVMXC__Preferred_Technician__c != oldWo.SVMXC__Preferred_Technician__c){
            schedulingChangeToken = 'CHANGE_PREFERRED_TECH';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c !='New' && newWO.SVMXC__Preferred_Business_Hours__c != oldWo.SVMXC__Preferred_Business_Hours__c){
            schedulingChangeToken = 'CHANGE_ACCESS_HOURS';
            isQualifyAndMark = true;
        } else if(!newWO.SVMXC__Locked_By_DC__c && newWO.SVMXC__Dispatch_Status__c !='New' && newWO.SVMXC__Preferred_Start_Time__c != oldWo.SVMXC__Preferred_Start_Time__c){
            schedulingChangeToken = 'CHANGE_PREFERRED_TIME';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c !='New' && newWO.SVMXC__Preferred_End_Time__c != oldWo.SVMXC__Preferred_End_Time__c){
            schedulingChangeToken = 'CHANGE_PREFERRED_TIME';
            isQualifyAndMark = true;
        }else if(!isExternalWO && newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Locked_By_DC__c != oldWO.SVMXC__Locked_By_DC__c) {
            schedulingChangeToken = 'CHANGE_JOB_UNFIXED';
            isQualifyAndMark = true;
        } else if(!isExternalWO && newWO.SVMXC__SM_Lock_Appointment_Schedule__c == null && oldWo.SVMXC__SM_Lock_Appointment_Schedule__c ==WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE) {
            schedulingChangeToken = 'CHANGE_JOB_UNFIXED';
            isQualifyAndMark = true;           
        } else if(newWO.SVMXC__Locked_By_DC__c == false && newWO.SVMXC__Dispatch_Status__c =='Assigned' && (newWO.SVMXC__SM_Lock_Appointment_Schedule__c == null || newWO.SVMXC__SM_Lock_Appointment_Schedule__c == 'None') && oldWo.SVMXC__SM_Lock_Appointment_Schedule__c ==WSCH_ECO_Constants.SCHEDULE_LOCK_TO_ARRIVALWINDOW){ 
            schedulingChangeToken = 'CHANGE_SCHEDULE_UNLOCK';
            isQualifyAndMark = true;        
        } else if(newWO.SVMXC__Locked_By_DC__c == false && 'CHANGE_RESOURCE_PREFERENCE'.equalsIgnoreCase(oldWo.SVMXC__Scheduling_Change_Token__c)) {
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
        } else if(newWO.SVMXC__Locked_By_DC__c == false && !isAppointmentWO(newWO) && newWO.SVMXC__Dispatch_Priority__c != oldWo.SVMXC__Dispatch_Priority__c){
            schedulingChangeToken = 'CHANGE_PRIORITY';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && !isAppointmentWO(newWO) && newWO.SVMXC__Contact__c != oldWo.SVMXC__Contact__c) {
            schedulingChangeToken = 'CHANGE_CONTACT_INFO';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && !isAppointmentWO(newWO) && newWO.SVMXC__Company__c != oldWo.SVMXC__Company__c) {
            schedulingChangeToken = 'CHANGE_ACCOUNT_INFO';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && !isAppointmentWO(newWO) && isAddressInfoChange(newWO, oldWO)) {
            schedulingChangeToken = 'CHANGE_ADDRESS_INFO';
            isQualifyAndMark = true;
        } else if((!isCancelledWO) && (setWODispStatus.contains(oldWo.SVMXC__Work_Order_Scheduling_Status__c)) && (newWO.SVMXC__Work_Order_Scheduling_Status__c == 'Fixed')){
            schedulingChangeToken = 'CHANGE_JOB_STATUS_FIXED';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Work_Order_Scheduling_Status__c != oldWo.SVMXC__Work_Order_Scheduling_Status__c){
            schedulingChangeToken = 'CHANGE_SCHEDULING_STATUS';
            isQualifyAndMark = true;
        } else if(newWO.SVMXC__Locked_By_DC__c == false && isValidDP){
            if(oldWo.SVMXC__Dispatch_Process__c != null && newWO.SVMXC__Dispatch_Process__c != oldWo.SVMXC__Dispatch_Process__c) {
                schedulingChangeToken = 'CHANGE_DISPATCH_PROCESS';
                isQualifyAndMark = true;
            } else if(oldWo.SVMXC__Dispatch_Process__c == null && newWO.SVMXC__Dispatch_Process__c != oldWo.SVMXC__Dispatch_Process__c) {
                schedulingChangeToken = 'CHANGE_CREATE_WO';
                isQualifyAndMark = true;
            }
        }

        if (newWO.SVMXC__Locked_By_DC__c != false && schedulingChangeToken == '') {
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::markChangeToken:: Skip this update for ForceFix Call/Job is already Fixed. Any changes to the fields affecting scheduling should not be performed.');
            String errorText = 'Skip this update for ForceFix Call./Job is already Fixed, So any changes to the fields affecting scheduling should not be performed.';
            WSCH_CommonUtils.setOptimizerErrorText(newWO, errorText);
        }else if(isExternalWO && newWO.SVMXC__Locked_By_DC__c == false && schedulingChangeToken == ''){
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::markChangeToken:: Skip this update for External work order is already fixed.');
            String errorText = 'Skip this update for External work order is already fixed.';
            WSCH_CommonUtils.setOptimizerErrorText(newWO, errorText);
        }
        
        /*new change token introduced for Book Dependency API call 
        */
        /*if(WSCH_Constants.BOOKJOB_SCHDL_CHANGE_TOKENS.contains(schedulingChangeToken) 
            || WSCH_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS.contains(schedulingChangeToken)
                && newWO.SVMXC__Dependency_Group__c != null && oldWO.SVMXC__Scheduling_Change_Token__c == null){
            schedulingChangeToken = 'CREATE_DEPENDENCY_WO';
            isQualifyAndMark = true;                
        }*/

        if(WSCH_Constants.BOOKJOB_SCHDL_CHANGE_TOKENS.contains(schedulingChangeToken) 
                && newWO.SVMXC__Dependency_Group__c != null && oldWO.SVMXC__Scheduling_Change_Token__c == null){
            schedulingChangeToken = 'CREATE_DEPENDENCY_WO';
            isQualifyAndMark = true;                
        }

        if(WSCH_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS.contains(schedulingChangeToken) 
            && newWO.SVMXC__Dependency_Group__c != null && oldWO.SVMXC__Scheduling_Change_Token__c != null){
            schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;                
        }

        if(schedulingChangeToken.equals('CHANGE_CANCEL_WO') && newWO.SVMXC__Dependency_Group__c != null){
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::markChangeToken:: Skip this update for cancel Job because it is scheduled to be part of dependency group');
            String errorText = 'Job is scheduled to be part of dependency group, first cancel the dependency manually and try again';
            WSCH_CommonUtils.setOptimizerErrorText(newWO, errorText);
            isQualifyAndMark = false;
        }

        /*
            If existing SVMXC__Scheduling_Change_Token__c is of higher priority then the new Scheduling change token, Then this function doesn't update it.
        */
        if (isQualifyAndMark) {
            newWO.SVMXC__Scheduling_Change_Token__c = getChangeToken(oldWO.SVMXC__OptiMax_Status__c,oldWO.SVMXC__Scheduling_Change_Token__c,schedulingChangeToken);
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::markChangeToken::Scheduling Change Token : '+newWO.SVMXC__Scheduling_Change_Token__c);
        }
        String strSchedToken = '';
        if((isQualifyAndMark) && (newWO.SVMXC__OptiMax_Status__c != WSCH_ECO_Constants.STATUS_OPT_BATCH) && ((isSmaxQSettingEnabled != null) && (isSmaxQSettingEnabled))){
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
            if(newWO != null && newWO.SVMXC__Dispatch_Process__c != NULL){
                if(svmxProcessMap.ContainsKey(newWO.SVMXC__Dispatch_Process__c) && newWO.SVMXC__QTL_Status__c != 'No Qualified Technicians (Disallow)') {
                    isSlaWO = true;
                }
            }           
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::isBookJobWO: ' + isSlaWO);
        return isSlaWO;
    }

    // Identifying logic for Dependency WOs
    public static boolean isDependencyJobWO(SVMXC__Service_Order__c newWO, Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap) {
        Boolean isDependencyWO = false;
        if(newWO != null && newWO.SVMXC__Dispatch_Process__c != NULL && newWO.SVMXC__Dependency_Group__c != null){
            if(svmxProcessMap.ContainsKey(newWO.SVMXC__Dispatch_Process__c)) {
                isDependencyWO = true;
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::isDependencyJobWO: ' + isDependencyWO + 'Dispatch Process: ' + svmxProcessMap);
            }
        }           
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::isDependencyJobWO: ' + isDependencyWO);
        return isDependencyWO;
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
        
        //String strCustomFields = WSCH_CommonUtils.getSettingValue('OMAX004','SET009');  //bookJob fields
        String strCustomFields = strBookJobCustomFields;
        //below code adds only the rebookJob custom fields into bookJobCustFieldsSet Set
        if(String.isNotBlank(strCustomFields)) {
            String[] customFieldsSplit = strCustomFields.split(',');
            for(String changeField : customFieldsSplit){
                bookJobCustFieldsSet.add(changeField);
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getCustomFieldsFromSettings::bookJobCustFieldsSet : ' + bookJobCustFieldsSet);
        return bookJobCustFieldsSet;
    }
    
  
    public static List<String> getCustomFieldsFromSettings(){
        List<String> lstOfCustomFields = new List<String>();
        lstOfCustomFields.addAll(getBookJobFieldsFromSettings());
        //lstOfCustomFields.addAll(getUpdateJobFieldsFromSettings());
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getCustomFieldsFromSettings::lstOfCustomFields : ' + lstOfCustomFields);
        return lstOfCustomFields;
    }       
    
    // Qualification logic for Book appointment work order related changes
    public static boolean isAppointmentWO(SVMXC__Service_Order__c newWO) {

        Boolean isApptWO = false;
        //if(newWO != null && newWO.SVMXC__Appointment_Promised_Time_Slot__c != null){
        if(newWO != null && newWO.SVMXC__Appointment_Promised_Time_Slot__c != null ){//Appt WO 
            isApptWO = true;
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::isAppointmentWO::isApptWO :'+isApptWO);
        }
        return isApptWO;
    }
    
    public static boolean isForceScheduleBookedWO(SVMXC__Service_Order__c oldWO) {
        //Set<String> strSetValidOptStatus = new Set<String>{WSCH_ECO_Constants.STATUS_OPT_FAIL, WSCH_ECO_Constants.STATUS_OPT_ERROR, WSCH_ECO_Constants.STATUS_OPT_COMPLETED, WSCH_ECO_Constants.STATUS_OPT_DATA_SYNC_ERROR};
        Set<String> strWOSchedulingStatus = new Set<String>{'--None--','SVMX.NONE','SVMX.None'};
        
        Boolean isForceScheduleBooked = false;
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::isForceScheduleBookedWO::oldWO.SVMXC__OptiMax_Status__c - ' + oldWO.SVMXC__OptiMax_Status__c);
        if(oldWO != null && oldWO.SVMXC__Scheduling_Change_Token__c != null && (WSCH_ECO_Constants.BOOKJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__OptiMax_Status__c)
                || WSCH_ECO_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__OptiMax_Status__c) 
                    || WSCH_ECO_Constants.FORCEFIXJOB_SCHDL_CHANGE_TOKENS.contains(oldWO.SVMXC__OptiMax_Status__c) 
                        || oldWO.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase('FORCE_SCHEDULE')) && !(strWOSchedulingStatus.contains(oldWO.SVMXC__Work_Order_Scheduling_Status__c))) {
            isForceScheduleBooked = true;
        }
        
        //below condition added to identify forcefix work order which was manually scheduled by DC and scheduling change token, optimax status not set any values.
        //if(oldWO.SVMXC__Locked_By_DC__c && oldWO.SVMXC__Dispatch_Status__c !='New')
            //isForceScheduleBooked = true;
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::isForceScheduleBookedWO::isForceScheduleBooked :'+isForceScheduleBooked);
        return isForceScheduleBooked;
   }
   
    // Qualification logic for identifying External work order 
    public static boolean getIsExternalWO(SVMXC__Service_Order__c newWO, SVMXC__Service_Order__c oldWO, Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap) {
        Boolean isExtWO = false;
            if(newWO != null && newWO.SVMXC__Primary_Territory__c == NULL && newWO.SVMXC__Group_Member__c != null) {
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getIsExternalWO::only WO Technician is present.');
                for(SVMXC__SVMX_Jobs__c jobs : listJob){
                    if(jobs.SVMXC__Territory__c == mapOfTechIdAndTerritoryId.get(newWO.SVMXC__Group_Member__c) && newWO.SVMXC__Dispatch_Status__c !='New'){
                        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getIsExternalWO::Technicians territory is RTO territory.Hence consider that.');
                        isExtWO = true;
                        break;
                    }
                } 
            } else if(newWO != null && newWO.SVMXC__Primary_Territory__c != NULL && newWO.SVMXC__Group_Member__c != null) {
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getIsExternalWO::WO Primary territory and technician is present');
                for(SVMXC__SVMX_Jobs__c jobs : listJob){
                    if(jobs.SVMXC__Territory__c == mapOfTechIdAndTerritoryId.get(newWO.SVMXC__Group_Member__c) && newWO.SVMXC__Dispatch_Status__c !='New' ){
                        if(newWO.SVMXC__Primary_Territory__c != mapOfTechIdAndTerritoryId.get(newWO.SVMXC__Group_Member__c)){
                            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getIsExternalWO::Technician territory and WO territory is different but Technician is in RTO territory.Hence consider that.');
                            isExtWO = true;
                        }
                        break;
                    }
                } 
            }                      
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getIsExternalWO: isExtWO ' + isExtWO);
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getIsExternalWO: isWOTerritoryORTechChanged ' + isWOTerritoryORTechChanged);
        return isExtWO;
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
            Map<String, String> mapOfqualifiedWoNameDpTerriIds = getQualifiedCancelWOIds(workorderList);
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::doQualifyCancelWorkorder(): Qualified WOIds for delete :'+mapOfqualifiedWoNameDpTerriIds);

            //creating a list of WO Ids from the map<woName, Id>
            List<String> qualifiedWONames;
            Set<String> woNameSet = new Set<String>();
            if(mapOfqualifiedWoNameDpTerriIds != null && mapOfqualifiedWoNameDpTerriIds.size() > 0) {
                woNameSet = mapOfqualifiedWoNameDpTerriIds.keySet();
            }
            
            if(woNameSet != null && woNameSet.size() > 0) {
                qualifiedWONames = new List<String>(woNameSet);
            }
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::doQualifyCancelWorkorder(): Qualified WONames for delete :'+qualifiedWONames);
            
            // Check if the DP is in FAILED or IDLE status
            List<String> lstDPIdsTerrIds = mapOfqualifiedWoNameDpTerriIds.values();
            List<String> lstDPIds = new List<String>();
            for(String st : lstDPIdsTerrIds){
              lstDPIds.add(st.split('_').get(0));
            }
            List<SVMXC__SVMX_Jobs__c> listJob = [SELECT SVMXC__Territory__c, SVMXC__OptiMax_Message__c from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :lstDPIds];        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            Map<String, String> mapTerrIdDPStatus = new Map<String, String>();
            for(SVMXC__SVMX_Jobs__c jobs : listJob){
                mapTerrIdDPStatus.put(jobs.SVMXC__Territory__c, jobs.SVMXC__OptiMax_Message__c);
            }
            
            if(mapOfqualifiedWoNameDpTerriIds != null && mapOfqualifiedWoNameDpTerriIds.size() > 0){
                list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = new list<SVMXC__SVMX_Optimizer__c>();
                String terrId = '';
                list<String> qualifiedWOs = new List<String>(); 
                for (String eachWoName : qualifiedWONames) {
                    terrId = mapOfqualifiedWoNameDpTerriIds.get(eachWoName).split('_').get(1);
                    if(mapTerrIdDPStatus.get(terrId).equalsIgnoreCase('IDLE') || mapTerrIdDPStatus.get(terrId).equalsIgnoreCase('FAILED')){
                        continue;
                    }else{
                       qualifiedWOs.add(eachWoName);
                    }
                    SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
                    optimizer.SVMXC__WhatId__c = eachWoName; 
                    optimizer.SVMXC__Optimizer_Connection_ID__c =mapOfqualifiedWoNameDpTerriIds.get(eachWoName); //DispatchProcess Id_Territory Id                  
                    optimizer.SVMXC__WhatType__c = 'WORK_ORDER';
                    optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CANCEL_WO';
                    optimizer.SVMXC__Optimizer_Status__c = isFutureContext? WSCH_ECO_Constants.STATUS_OPT_BATCH : WSCH_ECO_Constants.STATUS_OPT_PENDING;
                    optimizer.SVMXC__Optimizer_Retry_Count__c = 0;
                    lstSVMXOptimizer.add(optimizer);
                }
                
                //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::doQualifyCancelWorkorder(): Qualified WONames for delete lstSVMXOptimizer :'+lstSVMXOptimizer);     
                                
                if(lstSVMXOptimizer.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSVMXOptimizer, COMM_SecurityUtils.Access.Createable)){     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        insert lstSVMXOptimizer;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                                
                if(qualifiedWOs.size() > 0){
                    //check source call is future or batch and to avoid further future call.
                    if(isFutureContext) {
                        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::doQualifyCancelWorkorder()::Source is a FutureCall/Batch, So mark the workOrder for Batch execution :'+qualifiedWOs);
                        //WSCH_BA_ScheduleHandler.startBatchApex(WSCH_ECO_Constants.CANCEL_WO_BATCH_APEX, WSCH_ECO_Constants.BATCH_APEX_START_TIME);
                    } else {
                        cancelWorkOrders(qualifiedWOs);
                    }
                }
            }
            WSCH_AuditLogger.finish();
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_TriggerHandler:doQualifyCancelWorkorder() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    //Commented the above method. Added this method to return the Map<woName, Id>
    public static Map<String, String> getQualifiedCancelWOIds(List<SVMXC__Service_Order__c> workorderList){

        Map<String, String> mapOfWoNameDpTerriId = new Map<String, String>();
        Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap = WSCH_CommonUtils.getEcoDP();

        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:getQualifiedCancelWOIds(): svmxProcessMap - ' + svmxProcessMap.size());
        List<SVMXC__SVMX_Jobs__c> listJob = [SELECT Id, SVMXC__SVMX_Process__c, SVMXC__SVMX_Process__r.SVMXC__Child_Object_Criteria__c, SVMXC__SVMX_Process__r.SVMXC__Advance_Expression__c, SVMXC__Territory__c, SVMXC__OptiMax_Message__c from SVMXC__SVMX_Jobs__c where SVMXC__SVMX_Process__c = :svmxProcessMap.keySet()];       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        //To stop callout while deleting a LTP workorder
        set<String> setLTPDpId = new set<String>();
        for(SVMXC__Service_Order__c currWorkOrder : workorderList) {
            setLTPDpId.add(currWorkOrder.SVMXC__Dispatch_Process__c);
        }
        List<SVMXC__ServiceMax_Config_Data__c>  lstLTPConfigData = Database.Query('Select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId, SVMXC__Display_Type__c, SVMXC__Field_Relationship_Name__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =:setLTPDpId and SVMXC__Expression_Type__c =\'DISP_Schedule_Exp\'');
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:getQualifiedCancelWOIds(): lstLTPConfigData - ' + lstLTPConfigData);
        COMM_SVMXC_Utils4 oUtils = new COMM_SVMXC_Utils4();

        for(SVMXC__Service_Order__c currWorkOrder : workorderList) {
            Boolean isLTPQulaified = oUtils.SVMX_ExpressionParsing((SObject)currWorkOrder, lstLTPConfigData, Null, True);
            //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:getQualifiedCancelWOIds(): isLTPQulaified - ' + isLTPQulaified);
            if(isLTPQulaified || currWorkOrder.SVMXC__Locked_By_DC__c == true){
                continue;
            }
            
            //added check if WO is dispatched and scheduled date is past date, don't qualify for cancel
            Date dtToday = DateTime.now().DateGmt();
            if(('Dispatched'.equalsIgnoreCase(currWorkOrder.SVMXC__Work_Order_Scheduling_Status__c) 
                && (currWorkOrder.SVMXC__Scheduled_Date_Time__c).DateGmt() < dtToday)) {
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:getQualifiedCancelWOIds(): Work Order ' + currWorkOrder.Name + ' is already dispatched and is in past date');
                continue;
            }
            //if(currWorkOrder.SVMXC__OptiMax_Status__c != null && !('Canceled'.equalsIgnoreCase(currWorkOrder.SVMXC__Order_Status__c)) && svmxProcessMap.ContainsKey(currWorkOrder.SVMXC__Dispatch_Process__c)) {
            if(currWorkOrder.SVMXC__OptiMax_Status__c != null && !('Canceled'.equalsIgnoreCase(currWorkOrder.SVMXC__Order_Status__c))) {
                String dpTerritoryId;
                if(svmxProcessMap.ContainsKey(currWorkOrder.SVMXC__Dispatch_Process__c)){
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:getQualifiedCancelWOIds(): RTO work order having dispatch process...');
                    dpTerritoryId = currWorkOrder.SVMXC__Dispatch_Process__c+'_'+currWorkOrder.SVMXC__Primary_Territory__c;
                    mapOfWoNameDpTerriId.put(WSCH_CommonUtils.getWorkItemId('Name',currWorkOrder), dpTerritoryId);                  
                } else if(currWorkOrder.SVMXC__Appointment_Promised_Time_Slot__c != null || currWorkOrder.SVMXC__Primary_Territory__c != null){
                    //consider this is appointment work order 
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:getQualifiedCancelWOIds(): Appointment work order not having dispatch process or external WO with only RTO territory....');
                    for(SVMXC__SVMX_Jobs__c jobs : listJob){
                        if(jobs.SVMXC__Territory__c == currWorkOrder.SVMXC__Primary_Territory__c){
                            dpTerritoryId = jobs.SVMXC__SVMX_Process__c+'_'+currWorkOrder.SVMXC__Primary_Territory__c;
                        }
                    } 
                    mapOfWoNameDpTerriId.put(WSCH_CommonUtils.getWorkItemId('Name',currWorkOrder), dpTerritoryId);                  
                } /*else if(currWorkOrder.SVMXC__Group_Member__c != null && mapOfTechIdTechObj.containsKey(currWorkOrder.SVMXC__Group_Member__c)) {
                    //populate the map by fetching the territoryID from the technician map
                    mapOfWoNameDpTerriId.put(WSCH_CommonUtils.getWorkItemId('Name',currWorkOrder), mapOfTechIdTechObj.get(currWorkOrder.SVMXC__Group_Member__c).SVMXC__Service_Territory__c);
                }*/
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:getQualifiedCancelWOIds(): mapOfWoNameDpTerriId - ' + mapOfWoNameDpTerriId);
        WSCH_AuditLogger.finish();
        return mapOfWoNameDpTerriId;
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
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:cancelWorkOrders(): lstSVMXOptimizer - ' + lstSVMXOptimizer);
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            WSCH_OptimizedSchedulingService.cancelWorkOrders(lstSVMXOptimizer);
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_TriggerHandler:cancelWorkOrders() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    /**
        Following method validates whether the new SVMXC__Scheduling_Change_Token__c should be updated.
     **/
    public static String getChangeToken (String currentStatus,String oldToken,String newToken) {
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangeToken::oldStatus: '+currentStatus);
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangeToken::oldToken: '+oldToken);
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangeToken::newToken: '+newToken);
        //to avoid recursive work order update and stop recursive calls.
        if(currentStatus == null && oldToken == null && !'CHANGE_JOB_FIXED'.equalsIgnoreCase(newToken)){
            return 'CHANGE_CREATE_WO';
        }
        String changeToken = newToken;
        Set<String> successOptimaxStatusSet = new Set<String> {WSCH_ECO_Constants.STATUS_OPT_TENTATIVE,WSCH_ECO_Constants.STATUS_OPT_COMPLETED,WSCH_ECO_Constants.STATUS_OPT_QUEUED,WSCH_ECO_Constants.STATUS_OPT_UNASSIGNED,WSCH_ECO_Constants.STATUS_OPT_SKIPPED};
        if (!successOptimaxStatusSet.contains(currentStatus)) {
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangeToken::validating priorties between old and new token and set high priority token as new token.');
            Integer oldChangeTokenRank = WSCH_ECO_Constants.CHANGE_TOKEN_PRIORITY.get(oldToken);
            Integer newChangeTokenRank = WSCH_ECO_Constants.CHANGE_TOKEN_PRIORITY.get(newToken);
            //If Priority not found assigning default values.
            oldChangeTokenRank = oldChangeTokenRank == null ? WSCH_ECO_Constants.CHANGE_TOKEN_DEFAULT_PRIORITY : oldChangeTokenRank;
            newChangeTokenRank = newChangeTokenRank == null ? WSCH_ECO_Constants.CHANGE_TOKEN_DEFAULT_PRIORITY : newChangeTokenRank;
            if(oldChangeTokenRank == Math.min(oldChangeTokenRank,newChangeTokenRank)) {
                changeToken = oldToken;
            }
        }
        return changeToken;
    }

   
    /**  
        This method compares the OldWO's from the map with the new list of WO's for custom fields change and returns the new WO list
    **/
    public static List<SVMXC__Service_Order__c> getChangedWOList(List<SVMXC__Service_Order__c> newWorkOrderList, Map<String, Map<String, Object>> oldWOIdFieldValuesMap) {
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:getChangedWOList(): before modification newWorkOrderList: ' + newWorkOrderList);
        Boolean isCustomFieldChanged = false;
        String schedulingChangeToken;
        List<SVMXC__Service_Order__c> finalWOList = new List<SVMXC__Service_Order__c>();
        Set<String> oldWoIdSet = oldWOIdFieldValuesMap.keySet();
        Set<String> bookJobCustFieldsSet = getBookJobFieldsFromSettings();
        //Set<String> updateJobCustFieldsSet = getUpdateJobFieldsFromSettings();
        
        for(Integer i=0; i<newWorkOrderList.size(); i++) {
            String strNewWOId = newWorkOrderList.get(i).Id;
            SVMXC__Service_Order__c eachWorkOrderObj = newWorkOrderList.get(i);
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangedWOList::Fetched WO Details: New Token - ' + eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c);
            Map<String, Object> woFieldValueMap = oldWOIdFieldValuesMap.get(strNewWOId);
                
            if(woFieldValueMap == null)
            continue;   
                
            //do the comparison of the custom fields from new and old WO's
            Set<String> strWOFields = woFieldValueMap.keySet();
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangedWOList::strWOFields : ' + strWOFields);
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangedWOList::bookJobCustFieldsSet : ' + bookJobCustFieldsSet);
            for(String eachWOField : strWOFields) {
                if(eachWOField != 'SVMXC__OptiMax_Status__c' && eachWOField != 'SVMXC__Scheduling_Change_Token__c' 
                        && eachWOField != 'WOId' && eachWOField != 'PROCESS_FURTHER') {
                    if(woFieldValueMap.get(eachWOField) != eachWorkOrderObj.get(eachWOField)) {
                        //check if the current custom field is a rebookJob custom field
                        if(bookJobCustFieldsSet.contains(eachWOField)) {
                            schedulingChangeToken = 'CHANGE_CUSTOM_FIELDS_BOOK';
                        } /* else if(updateJobCustFieldsSet.contains(eachWOField)) {
                            schedulingChangeToken = 'CHANGE_CUSTOM_FIELDS_UPDATE';
                        }*/
                    isCustomFieldChanged = true;
                    }
                }                               
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangedWOList::isCustomFieldChanged : ' + isCustomFieldChanged);
                if (isCustomFieldChanged) {
                    eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c = getChangeToken(String.valueOf(woFieldValueMap.get('SVMXC__OptiMax_Status__c')),String.valueOf(woFieldValueMap.get('SVMXC__Scheduling_Change_Token__c')),schedulingChangeToken);
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangedWOList::Scheduling Change Token : ' + eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c);
                }else if(strNewWOId.equalsIgnoreCase(String.valueOf(eachWorkOrderObj.id)) && 'CHANGE_RESOURCE_PREFERENCE'.equalsIgnoreCase(String.valueOf(woFieldValueMap.get('SVMXC__Scheduling_Change_Token__c')))){
                    eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c = getChangeToken(String.valueOf(woFieldValueMap.get('SVMXC__OptiMax_Status__c')),String.valueOf(woFieldValueMap.get('SVMXC__Scheduling_Change_Token__c')),schedulingChangeToken);
                    eachWorkOrderObj.SVMXC__Scheduling_Retry_Count__c = 0;
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangedWOList::Scheduling Change Token : ' + eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c);
                }
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangedWOList::woFieldValueMap.get(\'SVMXC__Scheduling_Change_Token__c\') : ' + woFieldValueMap.get('SVMXC__Scheduling_Change_Token__c'));
                WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangedWOList::eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c : ' + eachWorkOrderObj.SVMXC__Scheduling_Change_Token__c);
            }
            //populate the finalWOList with only those WOs whose oldToken != newToken
            if(woFieldValueMap.get('PROCESS_FURTHER') == true ||  (isCustomFieldChanged)) {
              finalWOList.add(eachWorkOrderObj);
            }
        }
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getChangedWOList::finalWOList : ' + finalWOList);
        return finalWOList;
    }
    //This method creates Optimizer Transaction records for each work order, which will be used to Optimize the batching
    public static void createOptTrans(Map<String,String> mapWo){
        //WSCH_AuditLogger.rca('Creating the Optimizer Transcation for the workorders (SVMXC__SVMX_Optimizer__c)');
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizer = new list<SVMXC__SVMX_Optimizer__c>();
        list<SVMXC__SVMX_Optimizer__c> lstExistingSVMXOptimizer = new list<SVMXC__SVMX_Optimizer__c>();
        Set<String> setStrQueueStatus = new Set<String>{'BATCH_QUEUED','BATCH_FAILED'};
        Integer RETRY_COUNT = 4;
        String strWhatType = 'ECO_WORK_ORDER';
        if(mapWo != null && mapWo.size() > 0){
            lstExistingSVMXOptimizer = [SELECT ID, SVMXC__WhatId__c, SVMXC__WhatType__c, SVMXC__Optimizer_Change_Token__c, SVMXC__Optimizer_Status__c, SVMXC__Optimizer_Error_Text__c, SVMXC__Optimizer_Retry_Count__c FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__WhatId__c IN : mapWo.keySet() AND SVMXC__Optimizer_Status__c IN :setStrQueueStatus AND  SVMXC__WhatType__c = :strWhatType AND SVMXC__Optimizer_Retry_Count__c < :RETRY_COUNT ORDER BY LastModifiedDate ASC];
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::createOptTrans() : lstExistingSVMXOptimizer : ' + lstExistingSVMXOptimizer);
        Map<String, SVMXC__SVMX_Optimizer__c> mapWhatIdOptRcrd = new Map<String, SVMXC__SVMX_Optimizer__c>(); 
        for(SVMXC__SVMX_Optimizer__c optRcrd : lstExistingSVMXOptimizer){
            mapWhatIdOptRcrd.put(optRcrd.SVMXC__WhatId__c, optRcrd);
        }   
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::createOptTrans() : mapWhatIdOptRcrd : ' + mapWhatIdOptRcrd);      
        try{
            if((isSmaxQSettingEnabled != null) && (isSmaxQSettingEnabled)){
                for (String woRec : mapWo.keySet()) {
                    SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
                    if(mapWhatIdOptRcrd != null && mapWhatIdOptRcrd.size() > 0 && mapWhatIdOptRcrd.get(woRec) != null){
                        optimizer = mapWhatIdOptRcrd.get(woRec);
                    }
                    optimizer.SVMXC__WhatId__c = woRec;                   
                    optimizer.SVMXC__WhatType__c = 'ECO_WORK_ORDER';
                    if(optimizer.SVMXC__WhatType__c != null && optimizer.SVMXC__WhatType__c != '' && optimizer.SVMXC__WhatType__c.equals('ECO_WORK_ORDER'))
                        optimizer.SVMXC__SM_Work_Order__c = woRec;
                    optimizer.SVMXC__Optimizer_Change_Token__c = mapWo.get(woRec);
                    optimizer.SVMXC__Optimizer_Status__c = 'BATCH_QUEUED';
                    optimizer.SVMXC__Optimizer_Retry_Count__c = 0;
                    lstSVMXOptimizer.add(optimizer);
                }
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSVMXOptimizer, COMM_SecurityUtils.Access.Upsertable)){
                    Database.upsert(lstSVMXOptimizer);
                }
                //WSCH_AuditLogger.finish();
            }
        }catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_TriggerHandler:createOptTrans() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        
    }
    public static Boolean getSmaxQSetting(){
        String setVal = '';
        Boolean isSmaxQEnabled =false;
        try{
            setVal = WSCH_CommonUtils.getSettingValue('OMAX004','SET004');

            if(String.isNotBlank(setVal)){
                isSmaxQEnabled = Boolean.valueOf(setVal);
            }
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: SmaxQSetting ' + isSmaxQEnabled);
        }catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_TriggerHandler:getSmaxQSetting() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return isSmaxQEnabled;
    }

    public static void updateWoOptStatus(SVMXC__Service_Order__c woStatus){
        if((isSmaxQSettingEnabled != null) && (isSmaxQSettingEnabled)){
            if(woStatus.SVMXC__OptiMax_Status__c != WSCH_ECO_Constants.STATUS_OPT_BATCH){
                woStatus.SVMXC__OptiMax_Status__c = WSCH_ECO_Constants.STATUS_OPT_QUEUED; 
            }
        }
        
    }    

    /** Workorder Qualification logic implemented in this method.*/
    public static List<String> getEcoWOIds(List<SVMXC__Service_Order__c> workorderList){
        List<String> qualifiedWOIds = new List<String>();
        Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        try{
            mapSVMXProcess = WSCH_CommonUtils.getEcoDP();
            // Get the list of all valid dispatch processes ids for eco
            for(SVMXC__Service_Order__c currWorkOrder : workOrderList){
                // added below code to avoid API call if the work worder is scheduled for dependency group booking 
                if(currWorkOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c == true){
                    WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::getEcoWOIds()::Removing Work Order from the List as the WO is scheduled to be part of dependency group: '+currWorkOrder);              
                    continue;
                }
                
                //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler:getEcoWOIds(): QTL Status'+currWorkOrder.SVMXC__QTL_Status__c);
                if(currWorkOrder != null && currWorkOrder.SVMXC__Locked_By_DC__c != true && currWorkOrder.SVMXC__QTL_Status__c != 'No Qualified Technicians (Disallow)' && (currWorkOrder.SVMXC__Dispatch_Process__c != NULL || currWorkOrder.SVMXC__OptiMax_Error_Occurred__c != true)){
                    if(mapSVMXProcess.ContainsKey(currWorkOrder.SVMXC__Dispatch_Process__c) && currWorkOrder.SVMXC__Primary_Territory__c != null){
                        qualifiedWOIds.add(currWorkOrder.Id);
                    }
                }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_TriggerHandler:getEcoWOIds() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }

        return qualifiedWOIds;
    }
    
    //Multi-resource and Multi-appointment
    //To check if a WO has more than one event.
    //Returns map of worokrderId and list of SVMX events
    public static map<String, List<SVMXC__SVMX_Event__c>> checkMultiSVMXEventsInWO(List<String> listWOIds)
    {
        map<String, List<SVMXC__SVMX_Event__c>> mapWOIdSvmxEvnt = new map<String, list<SVMXC__SVMX_Event__c>>();
        List<SVMXC__SVMX_Event__c> listSVMXEvents =  [Select Id, SVMXC__WhatId__c, SVMXC__Technician__c, SVMXC__IsAllDayEvent__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c In : listWOIds];
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: checkMultiSVMXEventsInWO : listSVMXEvents : ' + listSVMXEvents);   
        for(SVMXC__SVMX_Event__c svmxEvnt : listSVMXEvents){
            if(svmxEvnt.SVMXC__IsAllDayEvent__c == true){//if it is all day event then skip the callout.
                continue;
            }
            list<SVMXC__SVMX_Event__c> listSVMXEvnt = new list<SVMXC__SVMX_Event__c>();
            if(mapWOIdSvmxEvnt.containsKey(svmxEvnt.SVMXC__WhatId__c)){
                list<SVMXC__SVMX_Event__c> tmpLstSvmxEvnt = mapWOIdSvmxEvnt.get(svmxEvnt.SVMXC__WhatId__c);
                tmpLstSvmxEvnt.add(svmxEvnt);
                mapWOIdSvmxEvnt.put(svmxEvnt.SVMXC__WhatId__c,tmpLstSvmxEvnt);
            }else{
                listSVMXEvnt.add(svmxEvnt);
                mapWOIdSvmxEvnt.put(svmxEvnt.SVMXC__WhatId__c,listSVMXEvnt);
            }
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: checkMultiSVMXEventsInWO : mapWOIdSvmxEvnt : ' + mapWOIdSvmxEvnt);     
        return mapWOIdSvmxEvnt;
    }
    
    //Multi-resource and Multi-appointment
    //To check if a WO has more than one event.
    //Returns map of worokrderId and list of SF events
    public static map<String, List<Event>> checkMultiSFEventsInWO(List<String> listWOIds)
    {
        map<String, List<Event>> mapWOIdSFEvnt = new map<String, list<Event>>();
        List<Event> listSFEvents =  [select Id, WhatId, IsAllDayEvent, ownerId from Event where WhatId In : listWOIds];
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: checkMultiSFEventsInWO : listSFEvents : ' + listSFEvents); 
        for(Event sfEvent : listSFEvents){
            if(sfEvent.IsAllDayEvent == true){//if it is all day event then skip the callout.
                continue;
            }
            list<Event> listSFEvnt = new list<Event>();
            if(mapWOIdSFEvnt.containsKey(sfEvent.WhatId)){
                list<Event> tmpLstSFEvnt = mapWOIdSFEvnt.get(sfEvent.WhatId);
                tmpLstSFEvnt.add(sfEvent);
                mapWOIdSFEvnt.put(sfEvent.WhatId,tmpLstSFEvnt);
            }else{
                listSFEvnt.add(sfEvent);
                mapWOIdSFEvnt.put(sfEvent.WhatId,listSFEvnt);
            }
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler: checkMultiSFEventsInWO : mapWOIdSFEvnt : ' + mapWOIdSFEvnt);       
        return mapWOIdSFEvnt;
    }
    
    //Multi-resource and Multi-appointment
    //Handle the scenario when a workorder locked by DC made from true to false manually.
    public static set<String> lockedByDCTrueToFalse(List<SVMXC__Service_Order__c> listWOsLockByDCTrueToFalse){
        List<String> listWOIdsLockByDCTrueToFalse = new List<String>();
        List<String> listWhatIdsLockDCTrueToFalseSingleSVMXEvnt = new List<String>();
        List<SVMXC__Service_Order__c> listWOsLockDCTrueToFalseSingleSVMXEvnt = new List<SVMXC__Service_Order__c>();
        Map<String, SVMXC__Service_Order__c> mapWOIdsWOobj = new Map<String, SVMXC__Service_Order__c>();
        List<SVMXC__SVMX_Event__c> listSingleSVMXEvents =  new List<SVMXC__SVMX_Event__c>();
        for(SVMXC__Service_Order__c eachWO : listWOsLockByDCTrueToFalse) {
            listWOIdsLockByDCTrueToFalse.add(eachWO.id);
            mapWOIdsWOobj.put(eachWO.id, eachWO);
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::lockedByDCTrueToFalse:: listWOIdsLockByDCTrueToFalse : '+listWOIdsLockByDCTrueToFalse);
        
        //SVMX events-->
        map<String, List<SVMXC__SVMX_Event__c>> mapWOIdSvmxEvnt = null;
        if(listWOIdsLockByDCTrueToFalse != null && listWOIdsLockByDCTrueToFalse.size() > 0)
            mapWOIdSvmxEvnt = checkMultiSVMXEventsInWO(listWOIdsLockByDCTrueToFalse);
        WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::lockedByDCTrueToFalse:: mapWOIdSvmxEvnt : '+mapWOIdSvmxEvnt);
        Set<String> setWOwithMultiEvnts = new Set<String>();

        if(mapWOIdSvmxEvnt != null && mapWOIdSvmxEvnt.size() > 0){
            for(String woId : mapWOIdSvmxEvnt.keySet()){
                if(mapWOIdSvmxEvnt.get(woId).size() > 1){
                    //If the WO has multi events then update the Error Text and check the Locked By DC again back to true
                    mapWOIdsWOobj.get(woId).SVMXC__Scheduling_Change_Token__c = 'CHANGE_JOB_FIXED';
                    mapWOIdsWOobj.get(woId).SVMXC__Locked_By_DC__c = true;
                    mapWOIdsWOobj.get(woId).SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
                    mapWOIdsWOobj.get(woId).SVMXC__OptiMax_Error_Text__c = 'This workorder has more than one events so Locked By DC field cannot be unchecked';
                    mapWOIdsWOobj.get(woId).SVMXC__OptiMax_Status__c = WSCH_ECO_Constants.STATUS_OPT_COMPLETED;
                    setWOwithMultiEvnts.add(woId);
                }else if(mapWOIdSvmxEvnt.get(woId).size() == 1){
                    //If the WO has only one event then delete the optimizer records and make a manageworkorder callout
                    mapWOIdsWOobj.get(woId).SVMXC__SM_Lock_Appointment_Schedule__c = null;
                    listWOsLockDCTrueToFalseSingleSVMXEvnt.add(mapWOIdsWOobj.get(woId));
                    listSingleSVMXEvents.addAll(mapWOIdSvmxEvnt.get(woId));
                }
            }
        }
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::lockedByDCTrueToFalse:: listSingleSVMXEvents : '+listSingleSVMXEvents+' , listWOsLockDCTrueToFalseSingleSVMXEvnt : '+listWOsLockDCTrueToFalseSingleSVMXEvnt);
        
        List<String> lstTechIds = new List<String>();
        if(listSingleSVMXEvents != null && listSingleSVMXEvents.size() > 0){
            for(SVMXC__SVMX_Event__c svmxEvnt : listSingleSVMXEvents){
                 if(svmxEvnt.SVMXC__Technician__c != null)
                    lstTechIds.add(svmxEvnt.SVMXC__Technician__c);
            }       
        
            Map<Id,SVMXC__Service_Group_Members__c> techniciansMap= WSCH_ECO_CommonUtils.getTechnicians(lstTechIds);
            SVMXC__Service_Group_Members__c technician;
            for(SVMXC__SVMX_Event__c objEvent : listSingleSVMXEvents){
                technician = techniciansMap.get(objEvent.SVMXC__Technician__c);
                 if(null != technician){
                    listWhatIdsLockDCTrueToFalseSingleSVMXEvnt.add(objEvent.id+'_'+technician.name); 
                 }
            }
        }
        
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::lockedByDCTrueToFalse:: listWhatIdsLockDCTrueToFalseSingleSVMXEvnt : '+listWhatIdsLockDCTrueToFalseSingleSVMXEvnt);
        
        if(listWhatIdsLockDCTrueToFalseSingleSVMXEvnt != null && listWhatIdsLockDCTrueToFalseSingleSVMXEvnt.size() > 0 && listWOsLockDCTrueToFalseSingleSVMXEvnt != null && listWOsLockDCTrueToFalseSingleSVMXEvnt.size() > 0)
            deleteOptRcrdsAndManageworkorderCallout(listWhatIdsLockDCTrueToFalseSingleSVMXEvnt, listWOsLockDCTrueToFalseSingleSVMXEvnt);  
          
          
        //SF events-->
        List<Event> listSingleSFEvents =  new List<Event>();
        List<String> listWhatIdsLockDCTrueToFalseSingleSFEvnt = new List<String>();
        List<SVMXC__Service_Order__c> listWOsLockDCTrueToFalseSingleSFEvnt = new List<SVMXC__Service_Order__c>();
        map<String, List<Event>> mapWOIdSFEvnt = null;
        if(listWOIdsLockByDCTrueToFalse != null && listWOIdsLockByDCTrueToFalse.size() > 0)
            mapWOIdSFEvnt = checkMultiSFEventsInWO(listWOIdsLockByDCTrueToFalse);
        //WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::lockedByDCTrueToFalse:: mapWOIdSFEvnt : '+mapWOIdSFEvnt);
        
        if(mapWOIdSFEvnt != null && mapWOIdSFEvnt.size() > 0){
            for(String woId : mapWOIdSFEvnt.keySet()){
                if(mapWOIdSFEvnt.get(woId).size() > 1){
                    //If the WO has multi events then update the Error Text and check the Locked By DC again back to true
                    mapWOIdsWOobj.get(woId).SVMXC__Scheduling_Change_Token__c = 'CHANGE_JOB_FIXED';
                    mapWOIdsWOobj.get(woId).SVMXC__Locked_By_DC__c = true;
                    mapWOIdsWOobj.get(woId).SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
                    mapWOIdsWOobj.get(woId).SVMXC__OptiMax_Error_Text__c = 'This workorder has more than one events so Locked By DC field cannot be unchecked';
                    mapWOIdsWOobj.get(woId).SVMXC__OptiMax_Status__c = WSCH_ECO_Constants.STATUS_OPT_COMPLETED;
                    setWOwithMultiEvnts.add(woId);
                }else if(mapWOIdSFEvnt.get(woId).size() == 1){
                    //If the WO has only one event then delete the optimizer records and make a manageworkorder callout
                    mapWOIdsWOobj.get(woId).SVMXC__SM_Lock_Appointment_Schedule__c = null;
                    listWOsLockDCTrueToFalseSingleSFEvnt.add(mapWOIdsWOobj.get(woId));
                    listSingleSFEvents.addAll(mapWOIdSFEvnt.get(woId));
                }
            }
        }
        
        List<String> technicianIds = new List<String>();
        list<String> listOptmzrWhatIdsLockDCTrueToFalseSingleSFEvnt= new list<String> ();  
        if(listSingleSFEvents != null)
        technicianIds = WSCH_ECO_CommonUtils.getNonWOTechniciansFromSFEvents(listSingleSFEvents); 
        Map<Id,SVMXC__Service_Group_Members__c> techniciansMap= WSCH_ECO_CommonUtils.getTechnicians(technicianIds);
        //WSCH_AuditLogger.debug('WSCH_ECO_EventTriggerHandler : getEventIdAndOptimizers : techniciansMap : '+techniciansMap);
        Map<Id,SVMXC__Service_Group_Members__c> mapOwnerIDTechId = new Map<Id,SVMXC__Service_Group_Members__c>();
        //create ownerId map
        for(SVMXC__Service_Group_Members__c tech : techniciansMap.values()){
                if(tech.SVMXC__Salesforce_User__c != null)
                    mapOwnerIDTechId.put(tech.SVMXC__Salesforce_User__c, tech);   
        }        

        SVMXC__Service_Group_Members__c technician;
        if(listSingleSFEvents != null){
             for(Event objEvent : listSingleSFEvents){
                //technician = techniciansMap.get(objEvent.WhatId);
                technician = mapOwnerIDTechId.get(objEvent.OwnerId);
                if(null != technician){
                listOptmzrWhatIdsLockDCTrueToFalseSingleSFEvnt.add(objEvent.id+'_'+technician.name);
                }
             }
        }
        
        if(listOptmzrWhatIdsLockDCTrueToFalseSingleSFEvnt != null && listOptmzrWhatIdsLockDCTrueToFalseSingleSFEvnt.size() > 0 && listWOsLockDCTrueToFalseSingleSFEvnt != null && listWOsLockDCTrueToFalseSingleSFEvnt.size() > 0)
          deleteOptRcrdsAndManageworkorderCallout(listOptmzrWhatIdsLockDCTrueToFalseSingleSFEvnt, listWOsLockDCTrueToFalseSingleSFEvnt);      
        
        return setWOwithMultiEvnts;  
    }
    
    //Multi-resource and Multi-appointment
    public static void deleteOptRcrdsAndManageworkorderCallout(List<String> listWhatIdsLockDCTrueToFalseSingleEvnt, List<SVMXC__Service_Order__c> listWOsLockDCTrueToFalseSingleEvnt){
        if(listWhatIdsLockDCTrueToFalseSingleEvnt != null && listWhatIdsLockDCTrueToFalseSingleEvnt.size() > 0){
            List<SVMXC__SVMX_Optimizer__c> listOptRcrd = [Select id, SVMXC__Optimizer_Change_Token__c from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in: listWhatIdsLockDCTrueToFalseSingleEvnt];
            WSCH_AuditLogger.debug('WSCH_ECO_TriggerHandler::deleteOptRcrdsAndManageworkorderCallout:: listOptRcrd.size():'+listOptRcrd.size()); 
            for(SVMXC__SVMX_Optimizer__c optimizer : listOptRcrd){
                optimizer.SVMXC__Optimizer_Change_Token__c = WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_DELETE;
            }
            //Update the optimizer records with token 'CHANGE_DELETE_EVENT' for the workorders which old Lock By DC is true and new Lock by DC false and has only one event
            if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Optimizer__c') ){     //SDL-SVMX-DELETE-FLS-ENFORCED
                update listOptRcrd;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }   
        }
    }
    
}