public with sharing class WSCH_DependencyTriggerHandler{
    public static Boolean SyncFlag;
    public static List<SVMXC__Service_Order__c> relatedWorkOrders = new List<SVMXC__Service_Order__c>();
    public static List<String> dependentWorkOrderIds = new List<String>(); 
    
    public static Boolean getDependencySetting(){
        Boolean dependencySetting = false, boolGBL007 = false;
        try{
            String strGBL007 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007');
            boolGBL007 = Boolean.valueOf(strGBL007);
            dependencySetting = Boolean.valueOf(WSCH_CommonUtils.getSettingValue('DCON004', 'SET014'));
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_DependencyTriggerHandler :: getDependencySetting() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            dependencySetting = false;
            boolGBL007 = false;
        }
        if(Test.isRunningTest()){
            return true;
        }
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::getDependencySetting:: Dispatch Optimization:'+boolGBL007+'   Dependency Setting:'+dependencySetting);
        return (dependencySetting && boolGBL007) ;
        //return true;
    }
    
    
    //check if the optimizer setting is enabled in after insert trigger context.
    /*public static void doQualify(String dependencyGroupId, List<Service_Order_Dependency__c> dependencyList){   
        if(!Test.isRunningTest()){  
            if(!WSCH_CommonUtils.isOptimizerEnabled()) {
                return;
            }
        }
        
        WSCH_TriggerHandler.updateWorkOrders(dependentWorkOrderIds, WSCH_Constants.STATUS_OPT_PENDING, 'CREATE_DEPENDENCY_WO');
        WSCH_DependencyTriggerHandler.getBookDependencyRequestResponse(dependencyGroupId);
        //WSCH_OptimizedSchedulingService.manageDependencyGroup(dependencyGroupId, dependencyList);
    }*/
    //Method to identify and Optimize Dependency Group Booking API based on the work order field changes
    public static void doIdentifyDependencyGroupAPI(List<Service_Order_Dependency__c> newDependencyList,List<Service_Order_Dependency__c> oldDependencyList) {
        /*if(!Test.isRunningTest()){
            if(!WSCH_CommonUtils.isOptimizerEnabled()) {
                return;
            }
        }*/
        Set<String> qualifiedDependencyGroups = new Set<String>();
        for(Integer i=0; i<newDependencyList.size(); i++){
            if(markChangeToken(newDependencyList[i],oldDependencyList[i])){
                qualifiedDependencyGroups.add(newDependencyList[i].SVMXC__Dependency_Group__c);
            }
            else if(newDependencyList.size() != oldDependencyList.size()){
                qualifiedDependencyGroups.add(newDependencyList[i].SVMXC__Dependency_Group__c);
            }
        }
        if(qualifiedDependencyGroups != null){
            /*for (String multiJobId: qualifiedDependencyGroups){
                WSCH_DependencyTriggerHandler.getBookDependencyRequestResponse(multiJobId);
            }*/
            //RTO Dependency Booking API
            WSCH_DependencyTriggerHandler.manageDependencyBooking(qualifiedDependencyGroups);
        }
    }
    
    /*public static void deleteWODependencyFromGroup(List<Service_Order_Dependency__c> lstOfDeletedWODependencyRecord) {
        List<String> woIds = new List<String>();
        //fetch the WO ids from the dependency records which has been deleted
        if(lstOfDeletedWODependencyRecord != null && lstOfDeletedWODependencyRecord.size() > 0) {
            for(Service_Order_Dependency__c eachWODependency : lstOfDeletedWODependencyRecord) {
                woIds.add(eachWODependency.SVMXC__Primary_Work_Order__c);
                woIds.add(eachWODependency.SVMXC__Secondary_Work_Order__c);
            }
        }
        //query all the WOs whose Ids were retrieved above
        List<SVMXC__Service_Order__c> woList = WSCH_CommonUtils.fetchWorkOrders(woIds);
        List<SVMXC__Service_Order__c> wosToUpdate = new List<SVMXC__Service_Order__c>();
        WSCH_AuditLogger.debug('woList-->'+woList);
        
        //iterate all the above retrieved WOs and nullify the Dependency Group Id lookup
        if(woList != null && woList.size() > 0) {
            for(SVMXC__Service_Order__c eachWO : woList) {
                eachWO.SVMXC__Dependency_Group__c = null;
                wosToUpdate.add(eachWO);
            }
        }
        
        if(wosToUpdate.size() > 0) {
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( wosToUpdate, COMM_SecurityUtils.Access.Upsertable) ) {      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert wosToUpdate; 
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return;
            }
        }
        WSCH_AuditLogger.finish();
    }*/
    
    public static void deleteWODependencyFromGroup(List<Service_Order_Dependency__c> lstOfDeletedWODependencyRecord) {
        List<String> woIds = new List<String>();
        Set<String> setOfPrimaryWOIds = new Set<String>();
        Set<String> setOfSecondaryWOIds = new Set<String>();
        Set<String> setOfAllWOIds = new Set<String>();
        //fetch the WO ids from the dependency records which has been deleted
        //Create two sets. One with Primary WOid and other with Secondary WOid
        if(lstOfDeletedWODependencyRecord != null && lstOfDeletedWODependencyRecord.size() > 0) {
            for(Service_Order_Dependency__c eachWODependency : lstOfDeletedWODependencyRecord) {
                setOfPrimaryWOIds.add(eachWODependency.SVMXC__Primary_Work_Order__c);
                setOfSecondaryWOIds.add(eachWODependency.SVMXC__Secondary_Work_Order__c);
            }
        }

        setOfAllWOIds.addAll(setOfPrimaryWOIds);
        setOfAllWOIds.addAll(setOfSecondaryWOIds);

        if(setOfAllWOIds.size() > 0) {
            woIds.addAll(setOfAllWOIds);
        }
        //query all the WOs whose Ids were retrieved above
        List<SVMXC__Service_Order__c> woList = WSCH_CommonUtils.fetchWorkOrders(woIds);
        Map<Id,SVMXC__ServiceMax_Processes__c> svmxEcoProcessMap = WSCH_CommonUtils.getEcoDP();
        
        List<SVMXC__Service_Order__c> wosToUpdate = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> lstOfWOsToDel = new List<SVMXC__Service_Order__c>();
        if(woList != null && woList.size() > 0) {
        //iterate the woList and check if each of this Id is only PrimaryWOid and not a SecondaryWOid
        //If it is also not a SecondaryWOId, then add this to delete set. This is to avoid duplicate cancelWO call to server
            for(SVMXC__Service_Order__c eachWO: woList) {
                eachWO.SVMXC__Dependency_Group__c = null;
                if(eachWO.SVMXC__Schedule_As_A_Dependent_Work_Order__c) {
                    eachWO.SVMXC__Schedule_As_A_Dependent_Work_Order__c = false;
                }
                //qualify only the RTO WOs for cancellation
                if(svmxEcoProcessMap.ContainsKey(eachWO.SVMXC__Dispatch_Process__c) && 
                        setOfPrimaryWOIds.contains(eachWO.Id) && !setOfSecondaryWOIds.contains(eachWO.Id)) {
                    //This lstOfWOsToDel will contain only the PrimaryWOs to delete.
                    //if primary WOs are cancelled from server, the server automatically unassigns the
                    //secondary WO from server.
                    lstOfWOsToDel.add(eachWO);
                } else {
                    //This wosToUpdate will contain only the SecondaryWOs to update.
                    wosToUpdate.add(eachWO);
                }
            }
        }
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::deleteWODependencyFromGroup()::WOs to cancel from dependency: '+lstOfWOsToDel.size());
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::deleteWODependencyFromGroup()::WOs to update from dependency: '+wosToUpdate.size());

        if(lstOfWOsToDel.size() > 0) {
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstOfWOsToDel, COMM_SecurityUtils.Access.Upsertable) ) {        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                upsert lstOfWOsToDel;   
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return;
            }
        }
        
        if(wosToUpdate.size() > 0) {
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( wosToUpdate, COMM_SecurityUtils.Access.Upsertable) ) {      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                WSCH_OptimizedSchedulingService.triggerExecuted = true;
                WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
                upsert wosToUpdate; 
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return;
            }
        }
        WSCH_AuditLogger.finish();
    }
    
    //Method to identify and Optimize Dependency Group Booking API based on the work order field changes
    public static List<SVMXC__Service_Order_Dependency__c> getUpdatedDependencyGroupsForBatch(List<Service_Order_Dependency__c> newDependencyList,List<Service_Order_Dependency__c> oldDependencyList) {
        /*if(!Test.isRunningTest()){
            if(!WSCH_CommonUtils.isOptimizerEnabled()) {
                return null;
            }
        }*/
        
        List<SVMXC__Service_Order_Dependency__c>  qualifiedDependencyGroups = new List<SVMXC__Service_Order_Dependency__c>();
        for(Integer i=0; i<newDependencyList.size(); i++){
            if(markChangeToken(newDependencyList[i],oldDependencyList[i])){
                qualifiedDependencyGroups.add(newDependencyList[i]);
            }
            else if(newDependencyList.size() != oldDependencyList.size()){
                qualifiedDependencyGroups.add(newDependencyList[i]);
            }
        }
        return qualifiedDependencyGroups;
    }
    
    /*public static void doQualifyInsertDependencyForBatch(List<Service_Order_Dependency__c> newDependencyList, List<SVMXC__Service_Order__c> woList) {
        Set<SVMXC__Service_Order__c> dependencyGroupWoSet = new Set<SVMXC__Service_Order__c>();
        for(SVMXC__Service_Order__c WO: woList){
            for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: newDependencyList){
                if(WO.Id == groupDependencyRecords.SVMXC__Primary_Work_Order__c || WO.Id == groupDependencyRecords.SVMXC__Secondary_Work_Order__c) {
                    WO.SVMXC__Dependency_Group__c = groupDependencyRecords.SVMXC__Dependency_Group__c;
                    //checking if the WO is already present to avoid duplicate. This WO may already be part of this 
                    //list as it could have been a Secondary WO from a previous relation definition
                    if(!dependencyGroupWoSet.contains(WO)) {
                        dependencyGroupWoSet.add(WO);
                    }
                }
            }
            /*WO.SVMXC__Dependency_Group__c = Trigger.new[0].SVMXC__Dependency_Group__c;
            dependencyGroupWoList.add(WO);
        }
        
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependencyForBatch: dependencyGroupWoSet - ' + dependencyGroupWoSet);
        List<SVMXC__Service_Order__c> lstWOsToUpdate;
        if(dependencyGroupWoSet.size() > 0) {
            lstWOsToUpdate = new List<SVMXC__Service_Order__c>(dependencyGroupWoSet);
            update lstWOsToUpdate;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependencyForBatch:Updated the WO with the groupID');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependencyForBatch:lstWOsToUpdate.size() - ' + lstWOsToUpdate.size());
        }
        WSCH_AuditLogger.finish();
    }*/

    //Method to update the workorders with the dependency groupID on the WorkOrders when creating Work Order Dependency objects from SFM
    public static void doQualifyInsertDependency(List<Service_Order_Dependency__c> newDependencyList, List<SVMXC__Service_Order__c> woList) {
        
        try {
            Set<SVMXC__Service_Order__c> dependencyGroupWoSet = new Set<SVMXC__Service_Order__c>();
            List<SVMXC__Service_Order__c> lstOfRTODependencyWorkOrders = new List<SVMXC__Service_Order__c>();
            Map<Id,SVMXC__ServiceMax_Processes__c> svmxEcoProcessMap = WSCH_CommonUtils.getEcoDP();
            Map<Id,SVMXC__ServiceMax_Processes__c> svmxBatchProcessMap = WSCH_CommonUtils.getOptimizedBatchDP();
            Map<Id, SVMXC__Service_Order__c> mapOfWOIdWorkOrder = new Map<Id, SVMXC__Service_Order__c>();
            Set<Service_Order_Dependency__c> setOfFilteredDependencyObj = new Set<Service_Order_Dependency__c>();
            Set<SVMXC__Service_Order__c> setOfFilteredRTODependencyWOs = new Set<SVMXC__Service_Order__c>();

            for(SVMXC__Service_Order__c eachWO: woList) {
                mapOfWOIdWorkOrder.put(eachWO.Id, eachWO);
            }

            for(SVMXC__Service_Order__c WO: woList){
                //separate the RTO WOs so that RTO Dependency callout can be made.
                //set the schedule_change_token to CREATE_DEPENDENCY_WO
                if(WO.SVMXC__Dispatch_Process__c == null) {
                    WO.SVMXC__OptiMax_Error_Text__c = 'This WO does not qualify for the dependency booking as there is no valid Dispatch Process';
                    WO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                    WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependency: This WO, ' + WO.Name + ' does not qualify for the dependency booking as there is no valid Dispatch Process');
                }

                if(svmxEcoProcessMap.ContainsKey(WO.SVMXC__Dispatch_Process__c)) {
                    WO.SVMXC__Scheduling_Change_Token__c = 'CREATE_DEPENDENCY_WO';
                    WO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                    lstOfRTODependencyWorkOrders.add(WO);
                }

                if(!svmxEcoProcessMap.ContainsKey(WO.SVMXC__Dispatch_Process__c) 
                            && !svmxBatchProcessMap.ContainsKey(WO.SVMXC__Dispatch_Process__c)) {
                    WO.SVMXC__OptiMax_Error_Text__c = 'This WO does not qualify for the dependency booking as it does not have a ECO/Batch Dispatch Process';
                    WO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                    WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependency: This WO, ' + WO.Name + ' does not qualify for the dependency booking as it does not have a ECO/Batch Dispatch Process');
                }

                WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependency:lstOfRTODependencyWorkOrders.size() - ' + lstOfRTODependencyWorkOrders.size());
                WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependency:newDependencyList.size() - ' + newDependencyList.size());
                
                for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: newDependencyList){
                    if(WO.Id == groupDependencyRecords.SVMXC__Primary_Work_Order__c || WO.Id == groupDependencyRecords.SVMXC__Secondary_Work_Order__c) {
                        WO.SVMXC__Dependency_Group__c = groupDependencyRecords.SVMXC__Dependency_Group__c;
                        //checking if the WO is already present to avoid duplicate. This WO may already be part of this 
                        //list as it could have been a Secondary WO from a previous relation definition
                        if(!dependencyGroupWoSet.contains(WO)) {
                            dependencyGroupWoSet.add(WO);
                        }
                    }
                    //Start:RTO specific logic to validate both WOs in a dependency Object
                    //Updating the dependent WO with appropriate error message when the other WO does not have a valid RTO DP.
                    SVMXC__Service_Order__c primaryWO = mapOfWOIdWorkOrder.get(groupDependencyRecords.SVMXC__Primary_Work_Order__c);
                    SVMXC__Service_Order__c secondaryWO = mapOfWOIdWorkOrder.get(groupDependencyRecords.SVMXC__Secondary_Work_Order__c);
                    
                    if(primaryWO.SVMXC__Dispatch_Process__c == null) {
                        secondaryWO.SVMXC__OptiMax_Error_Text__c = 'The dependent Work Order ' + primaryWO.Name +' does not have a valid DP. Hence dependency call cannot be made.';
                        //secondaryWO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                        if(!dependencyGroupWoSet.contains(secondaryWO)) {
                            dependencyGroupWoSet.add(secondaryWO);
                        }
                    } else if(svmxEcoProcessMap.ContainsKey(secondaryWO.SVMXC__Dispatch_Process__c) && !svmxEcoProcessMap.ContainsKey(primaryWO.SVMXC__Dispatch_Process__c)) {
                        secondaryWO.SVMXC__OptiMax_Error_Text__c = 'The dependent Work Order ' + primaryWO.Name +' does not have a valid RTO DP. Hence dependency call cannot be made.';
                        //secondaryWO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                        if(!dependencyGroupWoSet.contains(secondaryWO)) {
                            dependencyGroupWoSet.add(secondaryWO);
                        }
                    } else if(svmxBatchProcessMap.ContainsKey(secondaryWO.SVMXC__Dispatch_Process__c) && !svmxBatchProcessMap.ContainsKey(primaryWO.SVMXC__Dispatch_Process__c)) {
                        secondaryWO.SVMXC__OptiMax_Error_Text__c = 'The dependent Work Order ' + primaryWO.Name +' does not have a valid Batch DP. Hence dependency call cannot be made.';
                        //secondaryWO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                        if(!dependencyGroupWoSet.contains(secondaryWO)) {
                            dependencyGroupWoSet.add(secondaryWO);
                        }
                    }

                    if(secondaryWO.SVMXC__Dispatch_Process__c == null) {
                        primaryWO.SVMXC__OptiMax_Error_Text__c = 'The dependent Work Order ' + secondaryWO.Name +' does not have a valid DP. Hence dependency call cannot be made.';
                        //primaryWO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                        if(!dependencyGroupWoSet.contains(primaryWO)) {
                            dependencyGroupWoSet.add(primaryWO);
                        }
                    } else if(svmxEcoProcessMap.ContainsKey(primaryWO.SVMXC__Dispatch_Process__c) &&!svmxEcoProcessMap.ContainsKey(secondaryWO.SVMXC__Dispatch_Process__c)) {
                        primaryWO.SVMXC__OptiMax_Error_Text__c = 'The dependent Work Order ' + secondaryWO.Name +' does not have a valid RTO DP. Hence dependency call cannot be made.';
                        //primaryWO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                        if(!dependencyGroupWoSet.contains(primaryWO)) {
                            dependencyGroupWoSet.add(primaryWO);
                        }
                    } else if(svmxBatchProcessMap.ContainsKey(primaryWO.SVMXC__Dispatch_Process__c) &&!svmxBatchProcessMap.ContainsKey(secondaryWO.SVMXC__Dispatch_Process__c)) {
                        primaryWO.SVMXC__OptiMax_Error_Text__c = 'The dependent Work Order ' + secondaryWO.Name +' does not have a valid Batch DP. Hence dependency call cannot be made.';
                        //primaryWO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                        if(!dependencyGroupWoSet.contains(primaryWO)) {
                            dependencyGroupWoSet.add(primaryWO);
                        }
                    }
                    //if either primary or secondary WOs does not have a valid RTO DP, do not add that dependency Object in the list
                    if(primaryWO.SVMXC__Dispatch_Process__c != null && svmxEcoProcessMap.ContainsKey(primaryWO.SVMXC__Dispatch_Process__c) && 
                            secondaryWO.SVMXC__Dispatch_Process__c != null && svmxEcoProcessMap.ContainsKey(secondaryWO.SVMXC__Dispatch_Process__c)) {
                        setOfFilteredDependencyObj.add(groupDependencyRecords);
                        setOfFilteredRTODependencyWOs.add(primaryWO);
                        setOfFilteredRTODependencyWOs.add(secondaryWO);
                    }
                    //End:RTO specific logic to validate both WOs in a dependency Object
                }
                /*WO.SVMXC__Dependency_Group__c = Trigger.new[0].SVMXC__Dependency_Group__c;
                dependencyGroupWoList.add(WO);*/
            }
            List<Service_Order_Dependency__c> lstOfFilteredDependencyObj = new List<Service_Order_Dependency__c>();
            List<SVMXC__Service_Order__c> lstOfFilteredRTODependencyWOs = new List<SVMXC__Service_Order__c>();
            if(setOfFilteredDependencyObj.size() > 0) {
                lstOfFilteredDependencyObj.addAll(setOfFilteredDependencyObj);
            }
            if(setOfFilteredRTODependencyWOs.size() > 0) {
                lstOfFilteredRTODependencyWOs.addAll(setOfFilteredRTODependencyWOs);
            }

            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependency: dependencyGroupWoSet - ' + dependencyGroupWoSet);
            List<SVMXC__Service_Order__c> lstWOsToUpdate;
            if(dependencyGroupWoSet.size() > 0) {
                lstWOsToUpdate = new List<SVMXC__Service_Order__c>(dependencyGroupWoSet);
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstWOsToUpdate, COMM_SecurityUtils.Access.Updateable) ) {       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update lstWOsToUpdate;
                }else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return;
                }
                WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependency:Updated the WO with the groupID');
                WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependency:lstWOsToUpdate.size() - ' + lstWOsToUpdate.size());
            }
            //If there are RTO Dependency WOs, then create the req and make the callout
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependency:filteredDependencyList.size() - ' + lstOfFilteredDependencyObj.size());
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependency:filteredLstOfRTODependencyWOs.size() - ' + lstOfFilteredRTODependencyWOs.size());
            if(lstOfFilteredRTODependencyWOs.size() > 0 && lstOfFilteredDependencyObj.size() > 0) {
                //create a set of all Dependency GroupIds
                Set<String> dependencyManagementId = new Set<String>();
                for(Service_Order_Dependency__c svcOdr: lstOfFilteredDependencyObj){
                    dependencyManagementId.add(svcOdr.SVMXC__Dependency_Group__c);
                }
                //RTO Dependency Booking API
                if(dependencyManagementId.size() > 0) {
                    WSCH_DependencyTriggerHandler.manageDependencyBooking(dependencyManagementId);
                }
            } else {
                WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyInsertDependency: there are no valid RTO dependency objects to make a call.');
            }
            WSCH_AuditLogger.finish();
        } catch(Exception ex){
            system.debug('Exception caught:WSCH_DependencyTriggerHandler:doQualifyInsertDependency() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.error('Exception caught:WSCH_DependencyTriggerHandler:doQualifyInsertDependency() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }

    //Method to update the workorders with the dependency groupID on the WorkOrders when updating the existing Work Order Dependency objects from SFM
    /*public static void doQualifyUpdatedDependencyForBatch(List<Service_Order_Dependency__c> newDependencyList,List<Service_Order_Dependency__c> oldDependencyList) {
        List<SVMXC__Service_Order_Dependency__c>  qualifiedDependencyGroups = WSCH_DependencyTriggerHandler.getUpdatedDependencyGroupsForBatch(newDependencyList, oldDependencyList);
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependencyForBatch: qualifiedDependencyGroups - ' + qualifiedDependencyGroups);
        
        if(qualifiedDependencyGroups == null || (qualifiedDependencyGroups != null && qualifiedDependencyGroups.size() == 0)) {
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependencyForBatch: No qualified dependency group for update found');
            return;
        }
        Set<String> WO_Ids = new Set<String>();
        for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: qualifiedDependencyGroups){
            WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Primary_Work_Order__c));
            WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Secondary_Work_Order__c));
        }
        Set<SVMXC__Service_Order__c> dependencyGroupWoSet = new Set<SVMXC__Service_Order__c>();
        List<String> WoIdList = new List<String>();
        WoIdList.addAll(WO_Ids);
        List<SVMXC__Service_Order__c> woList = WSCH_CommonUtils.fetchWorkOrders(WoIdList);
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependencyForBatch: woList-->'+woList);
        
        for(SVMXC__Service_Order__c WO: woList){
            for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: qualifiedDependencyGroups){
                if(WO.Id == groupDependencyRecords.SVMXC__Primary_Work_Order__c || WO.Id == groupDependencyRecords.SVMXC__Secondary_Work_Order__c) {
                    WO.SVMXC__Dependency_Group__c = groupDependencyRecords.SVMXC__Dependency_Group__c;
                    //checking if the WO is already present to avoid duplicate. This WO may already be part of this 
                    //list as it could have been a Secondary WO from a previous relation definition
                    if(!dependencyGroupWoSet.contains(WO)) {
                        dependencyGroupWoSet.add(WO);
                    }
                }
            }
            /*WO.SVMXC__Dependency_Group__c = qualifiedDependencyGroups[0].SVMXC__Dependency_Group__c;
            dependencyGroupWoList.add(WO);
        }
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependencyForBatch: dependencyGroupWoSet - ' + dependencyGroupWoSet);
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        List<SVMXC__Service_Order__c> lstWOsToUpdate;
        if(dependencyGroupWoSet.size() > 0) {
            lstWOsToUpdate = new List<SVMXC__Service_Order__c>(dependencyGroupWoSet);
            update lstWOsToUpdate;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependencyForBatch: Updated the WO with the groupID');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependencyForBatch: lstWOsToUpdate.size() - ' + lstWOsToUpdate.size());
        }
        WSCH_AuditLogger.finish();
    }*/

    //Method to update the workorders with the dependency groupID on the WorkOrders when updating the existing Work Order Dependency objects from SFM
    public static void doQualifyUpdatedDependency(List<Service_Order_Dependency__c> newDependencyList,List<Service_Order_Dependency__c> oldDependencyList) {
        List<SVMXC__Service_Order_Dependency__c>  qualifiedDependencyGroups = WSCH_DependencyTriggerHandler.getUpdatedDependencyGroupsForBatch(newDependencyList, oldDependencyList);
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependency: qualifiedDependencyGroups - ' + qualifiedDependencyGroups);
        
        if(qualifiedDependencyGroups == null || (qualifiedDependencyGroups != null && qualifiedDependencyGroups.size() == 0)) {
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependencyForBatch: No qualified dependency group for update found');
            return;
        }
        Set<String> WO_Ids = new Set<String>();
        for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: qualifiedDependencyGroups){
            WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Primary_Work_Order__c));
            WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Secondary_Work_Order__c));
        }
        Set<SVMXC__Service_Order__c> dependencyGroupWoSet = new Set<SVMXC__Service_Order__c>();
        List<String> WoIdList = new List<String>();
        WoIdList.addAll(WO_Ids);
        List<SVMXC__Service_Order__c> woList = WSCH_CommonUtils.fetchWorkOrders(WoIdList);
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependency: woList-->'+woList);

        List<SVMXC__Service_Order__c> lstOfRTOWorkOrders = new List<SVMXC__Service_Order__c>();
        Map<Id,SVMXC__ServiceMax_Processes__c> svmxEcoProcessMap = WSCH_CommonUtils.getEcoDP();
        Set<String> qualifiedRTODependencyGroups = new Set<String>(); 
        
        for(SVMXC__Service_Order__c WO: woList){
            //separate the RTO WOs so that RTO Dependency callout can be made.
            //set the schedule_change_token to CHANGE_DEPENDENCY_WO
            if(svmxEcoProcessMap.ContainsKey(WO.SVMXC__Dispatch_Process__c)) {
                WO.SVMXC__Scheduling_Change_Token__c = 'CHANGE_DEPENDENCY_WO';
                WO.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                lstOfRTOWorkOrders.add(WO);
            }
            for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: qualifiedDependencyGroups){
                if(WO.Id == groupDependencyRecords.SVMXC__Primary_Work_Order__c || WO.Id == groupDependencyRecords.SVMXC__Secondary_Work_Order__c) {
                    WO.SVMXC__Dependency_Group__c = groupDependencyRecords.SVMXC__Dependency_Group__c;
                    //checking if the WO is already present to avoid duplicate. This WO may already be part of this 
                    //list as it could have been a Secondary WO from a previous relation definition
                    if(!dependencyGroupWoSet.contains(WO)) {
                        dependencyGroupWoSet.add(WO);
                    }
                }
                //collect all the dep Group Ids from RTO WOs
                if(svmxEcoProcessMap.ContainsKey(WO.SVMXC__Dispatch_Process__c) && !qualifiedRTODependencyGroups.contains(WO.SVMXC__Dependency_Group__c)) {
                    qualifiedRTODependencyGroups.add(WO.SVMXC__Dependency_Group__c);
                }
            }
            /*WO.SVMXC__Dependency_Group__c = qualifiedDependencyGroups[0].SVMXC__Dependency_Group__c;
            dependencyGroupWoList.add(WO);*/
        }
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependency: dependencyGroupWoSet - ' + dependencyGroupWoSet);
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
        List<SVMXC__Service_Order__c> lstWOsToUpdate;
        if(dependencyGroupWoSet.size() > 0) {
            lstWOsToUpdate = new List<SVMXC__Service_Order__c>(dependencyGroupWoSet);
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstWOsToUpdate, COMM_SecurityUtils.Access.Updateable) ) {       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    update lstWOsToUpdate;
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return;
            }
            
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependency: Updated the WO with the groupID');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependency: lstWOsToUpdate.size() - ' + lstWOsToUpdate.size());
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependency: lstOfRTOWorkOrders.size() - ' + lstOfRTOWorkOrders.size());
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: doQualifyUpdatedDependency: qualifiedRTODependencyGroups.size() - ' + qualifiedRTODependencyGroups.size());
        }
        //If there are RTO Dependency WOs, then create the req and make the callout
        /*if(lstOfRTOWorkOrders.size() > 0) {
            //call doIdentifyDependencyGroupAPI() which evaluates the token and calls the dependencyBook()
            WSCH_DependencyTriggerHandler.doIdentifyDependencyGroupAPI(newDependencyList, oldDependencyList);
        }*/
        if(lstOfRTOWorkOrders.size() > 0 && qualifiedRTODependencyGroups.size() > 0) {
            WSCH_DependencyTriggerHandler.manageDependencyBooking(qualifiedRTODependencyGroups);
        }
        WSCH_AuditLogger.finish();
    }
    
    // Method to return the map of groupId to list of dependency records associated with it.
    public static Map<String, List<Service_Order_Dependency__c>> getDependencyMap(List<Service_Order_Dependency__c> WoDependencyList){
        Map<String, List<Service_Order_Dependency__c>> serviceOrderMap = new Map<String, List<Service_Order_Dependency__c>>();
        Set<String> dependencyManagementId = new Set<String>();
        Set<String> multiJobId = new Set<String>();

        List<SVMXC__Dependency_Management__c> dependencyManagementRecords = new List<SVMXC__Dependency_Management__c>();
        WSCH_AuditLogger.debug('WoDependencyList-->'+WoDependencyList);
        
        if(WoDependencyList == null) {
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler:getDependencyMap():WoDependencyList is empty or null: ' + WoDependencyList);
            return null;
        }
        
        for(Service_Order_Dependency__c svcOdr: WoDependencyList){
            dependencyManagementId.add(svcOdr.SVMXC__Dependency_Group__c);
        }
        
        try{
            for(String depGroup: dependencyManagementId){
                for(Service_Order_Dependency__c  svcOdr: WoDependencyList){
                    if(depGroup == svcOdr.SVMXC__Dependency_Group__c){
                        List<Service_Order_Dependency__c > serviceOrderlst = new List<Service_Order_Dependency__c >();
                        if(serviceOrderMap.containskey(depGroup)){
                            serviceOrderlst = serviceOrderMap.get(depGroup);
                            serviceOrderlst.add(svcOdr);
                            serviceOrderMap.put(depGroup, serviceOrderlst);
                        }
                        else{
                            serviceOrderlst.add(svcOdr);
                            serviceOrderMap.put(depGroup, serviceOrderlst);
                        }
                    }
                    
                }
            }
        }catch(exception ex){
            String exceptionMsg = 'WSCH_DependencyTriggerHandler :: getDependencyMap';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        WSCH_AuditLogger.debug('serviceOrderMap-->'+serviceOrderMap);
        return serviceOrderMap;
    }
    
    //RTO Dependency Booking API
    @future(callout=true)
    public static void manageDependencyBooking(Set<String> dependencyManagementId) {
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::manageDependencyBooking()::Start.');
        //fetching all the related dependencyObjects for a the group Ids fetched above
        List<SVMXC__Service_Order_Dependency__c> dependencyGroupList = new List<SVMXC__Service_Order_Dependency__c>();
        Map<Id, SVMXC__Service_Order__c> mapOfWOIdWorkOrder = new Map<Id, SVMXC__Service_Order__c>();
        Map<Id,SVMXC__ServiceMax_Processes__c> svmxEcoProcessMap = WSCH_CommonUtils.getEcoDP();
        List<SVMXC__Service_Order_Dependency__c> lstOfFilteredDependencyObj = new List<SVMXC__Service_Order_Dependency__c>();
        Set<SVMXC__Service_Order__c> setOfFilteredDependencyWOs = new Set<SVMXC__Service_Order__c>();

        //fetch all the dependency objects for all the groupIds received above
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
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: manageDependencyBooking(): dependencyGroupList.size() - ' + dependencyGroupList.size());
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: manageDependencyBooking(): woList.size() - ' + woList.size());
        
        //create a map of WOid and WO which is used below to create a filtered list of DependencyObj and DependencyWOs
        for(SVMXC__Service_Order__c eachWO: woList) {
            mapOfWOIdWorkOrder.put(eachWO.Id, eachWO);
        }

        //commented the below logic. This is handled in the previous method.
        //Create a filtered list of dependencyObj and dependencyWOs if they have RTO DP only.
        if(dependencyGroupList.size() > 0) {
            for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: dependencyGroupList){
                SVMXC__Service_Order__c primaryWO = mapOfWOIdWorkOrder.get(groupDependencyRecords.SVMXC__Primary_Work_Order__c);
                SVMXC__Service_Order__c secondaryWO = mapOfWOIdWorkOrder.get(groupDependencyRecords.SVMXC__Secondary_Work_Order__c);
                //if both primary and secondary WOs has a valid RTO DP only then add this DependencyObject to the filtered list
                if(svmxEcoProcessMap.ContainsKey(primaryWO.SVMXC__Dispatch_Process__c) &&
                            svmxEcoProcessMap.ContainsKey(secondaryWO.SVMXC__Dispatch_Process__c)) {
                    lstOfFilteredDependencyObj.add(groupDependencyRecords);
                    //also add the primary and secondary WOs to the new filtered listOfDepWOs
                    setOfFilteredDependencyWOs.add(primaryWO);
                    setOfFilteredDependencyWOs.add(secondaryWO);
                }
            }
        }
        
        List<SVMXC__Service_Order__c> lstOfFilteredDependencyWOs = new List<SVMXC__Service_Order__c>(setOfFilteredDependencyWOs);

        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: manageDependencyBooking(): lstOfFilteredDependencyObj.size() - ' + lstOfFilteredDependencyObj.size());
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: manageDependencyBooking(): lstOfFilteredDependencyWOs.size() - ' + lstOfFilteredDependencyWOs.size());

        if(lstOfFilteredDependencyObj.size() > 0 && lstOfFilteredDependencyWOs.size() > 0) {
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: manageDependencyBooking(): Before making manageDependencyBooking() call');
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
            WSCH_OptimizedSchedulingService.manageDependencyBooking(lstOfFilteredDependencyObj, lstOfFilteredDependencyWOs);
        } else {
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler: manageDependencyBooking(): could not make the dependencyCall as there are no valid dependency objects');
            WSCH_AuditLogger.finish();
        }
    }
    
    //initiate future callout for BookDependencyJob API call
    /*@future(callout = true)
    public static void getBookDependencyRequestResponse(String multiJobId){ 
        List<Service_Order_Dependency__c> serviceOrderList = new List<Service_Order_Dependency__c>();
        serviceOrderList = WSCH_CommonUtils.fetchGroupDependency(multiJobId);
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::getBookDependencyRequestResponse:: Work Order Dependency Records:'+serviceOrderList);
        WSCH_OptimizedSchedulingService.manageDependencyGroup(multiJobId, serviceOrderList);
    }*/
    
    //initiate future method for cancel book dependency group request
    /*@kundan- Commented this code as this functionality is not required for the current release.
    @future(callout = true)
    public static void cancelDependencyGroup(List<String> multiJobId, List<String> WoIds){ 
        //List<Service_Order_Dependency__c> serviceOrderList = new List<Service_Order_Dependency__c>();
        //serviceOrderList = WSCH_CommonUtils.fetchGroupDependency(multiJobId);
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::cancelDependencyGroup:: multiJobIDs to be cancelled:'+multiJobId);
        WSCH_OptimizedSchedulingService.cancelDependencyGroup(multiJobId, WoIds);
    }*/
    
    //validate work orders associated with WO depedency List in before Insert and before Update trigger context.
    public static void validateDependencyGroup(List<Service_Order_Dependency__c> svcOdrList, String multiJobId, String triggerContext){
        if(WSCH_DependencyTriggerHandler.getDependencySetting() == false){
            for(Service_Order_Dependency__c svcOrder: svcOdrList){
                svcOrder.addError(system.label.DCON003_TAG101);
            }
        }
        Boolean isLatestLessThenEarliest = false;
        Boolean isTargetTimeInvalid = false;
        Boolean isCostIdDoesNotExist = false;
        Boolean woIsPartOfDependentGroup = false;
        Boolean woDoNotQualify = false;
        Boolean hasMultipleConnectionNames = false;
        Decimal earliestTimeInMinutes;
        Decimal latestTimeInMinutes;
        Decimal targetTimeInMinutes;
        String WoDetail;
        Set<String> WOSetIds = new Set<String>();       
        try{
            for(Service_Order_Dependency__c serviceOrder : svcOdrList){
                WOSetIds.add(serviceOrder.SVMXC__Primary_Work_Order__c);
                WOSetIds.add(serviceOrder.SVMXC__Secondary_Work_Order__c);
                if(serviceOrder.SVMXC__Maximum_Time_Deviation__c != null){
                    if(serviceOrder.SVMXC__Maximum_Time_Deviation_Units__c == 'Hours'){
                        earliestTimeInMinutes = serviceOrder.SVMXC__Maximum_Time_Deviation__c * 60;
                    }
                    else if(serviceOrder.SVMXC__Maximum_Time_Deviation_Units__c == 'Days'){
                        earliestTimeInMinutes = serviceOrder.SVMXC__Maximum_Time_Deviation__c * 60 *60;
                    }
                    else if(serviceOrder.SVMXC__Maximum_Time_Deviation_Units__c == 'Minutes'){
                        earliestTimeInMinutes = serviceOrder.SVMXC__Maximum_Time_Deviation__c;
                    }
                }
                if(serviceOrder.SVMXC__Minimum_Time_Deviation__c != null){
                    if(serviceOrder.SVMXC__Minimum_Time_Deviation_Units__c == 'Hours'){
                        latestTimeInMinutes = serviceOrder.SVMXC__Minimum_Time_Deviation__c * 60;
                    }
                    else if(serviceOrder.SVMXC__Minimum_Time_Deviation_Units__c == 'Days'){
                        latestTimeInMinutes = serviceOrder.SVMXC__Minimum_Time_Deviation__c * 60 *60;
                    }
                    else if(serviceOrder.SVMXC__Minimum_Time_Deviation_Units__c == 'Minutes'){
                        latestTimeInMinutes = serviceOrder.SVMXC__Minimum_Time_Deviation__c;
                    }
                }
                if(serviceOrder.SVMXC__Targeted_Time_Difference__c != null){
                    if(serviceOrder.SVMXC__Targeted_Time_Variance_Cost_ID__c == '' || serviceOrder.SVMXC__Targeted_Time_Variance_Cost_ID__c == null){
                        isCostIdDoesNotExist = true;
                    }
                    if(serviceOrder.SVMXC__Targeted_Time_Difference_Units__c == 'Hours'){
                        targetTimeInMinutes = serviceOrder.SVMXC__Targeted_Time_Difference__c * 60;
                    }
                    else if(serviceOrder.SVMXC__Targeted_Time_Difference_Units__c == 'Days'){
                        targetTimeInMinutes = serviceOrder.SVMXC__Targeted_Time_Difference__c * 60 *60;
                    }
                    else if(serviceOrder.SVMXC__Targeted_Time_Difference_Units__c == 'Minutes'){
                        targetTimeInMinutes = serviceOrder.SVMXC__Targeted_Time_Difference__c;
                    }
                }
                if(latestTimeInMinutes < earliestTimeInMinutes){
                    isLatestLessThenEarliest = true;
                }
                else if(targetTimeInMinutes > latestTimeInMinutes || targetTimeInMinutes < earliestTimeInMinutes){
                    isTargetTimeInvalid = true;
                }
            }
            
            dependentWorkOrderIds.AddAll(WOSetIds);
            //WSCH_Provider_SP_RealTimeOptimizer realTimeOptimizer = new WSCH_Provider_SP_RealTimeOptimizer();
            //relatedWorkOrders = WSCH_CommonUtils.fetchWorkOrders(dependentWorkOrderIds);
            //WSCH_Provider_SP_RealTimeOptimizer.mapWoConName = new Map<Id, String>();
            //realTimeOptimizer.populateDispatchProcessSpURL(relatedWorkOrders);
            //Set<String> setOfConnectionName = new Set<String>(); 
            relatedWorkOrders = [SELECT Id, Name, SVMXC__Dependency_Group__c, SVMXC__Zip__c, SVMXC__Service_Duration__c, SVMXC__OptiMax_Status__c, SVMXC__Scheduling_Change_Token__c, SVMXC__Optimizer_Connection_Name__c, SVMXC__Dispatch_Process__r.SVMXC__Target_URL__c from SVMXC__Service_Order__c where ID IN: dependentWorkOrderIds];
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::validateDependencyGroup:WO in the Group:'+relatedWorkOrders);
            for(SVMXC__Service_Order__c WO: relatedWorkOrders){           
                //WSCH_Provider_SP_RealTimeOptimizer.getSpConnName(WO.SVMXC__Dispatch_Process__c, WO.SVMXC__Optimizer_Connection_Name__c, WO.Id);
                /*if(WO.SVMXC__Optimizer_Connection_Name__c != null){
                    setOfConnectionName.add(WO.SVMXC__Optimizer_Connection_Name__c);
                }
                else if(WO.SVMXC__Dispatch_Process__r.SVMXC__Target_URL__c != null){
                    setOfConnectionName.add(WO.SVMXC__Dispatch_Process__r.SVMXC__Target_URL__c);
                }
                if(setOfConnectionName.size() >1){
                    hasMultipleConnectionNames = true;
                }*/
                if(WO.SVMXC__Zip__c == '' || WO.SVMXC__Zip__c == null || WO.SVMXC__Service_Duration__c == null){
                    if(WoDetail != null){
                        WoDetail = WoDetail + ',' +WO.Name;
                    }else{
                        WoDetail = WO.Name;
                    }
                    woDoNotQualify = true;
                }
                else if(WO.SVMXC__Dependency_Group__c != null){
                    System.debug('multiJobId-->'+multiJobId+'WO.SVMXC__Dependency_Group__c-->'+WO.SVMXC__Dependency_Group__c);
                    if(triggerContext == 'beforeUpdate' && WO.SVMXC__Dependency_Group__c != multiJobId){
                        woIsPartOfDependentGroup = true;
                        if(WoDetail != null){
                            WoDetail = WoDetail + ',' +WO.Name;
                        }else{
                            WoDetail = WO.Name;
                        }
                    }
                    else if(triggerContext == 'beforeInsert'){
                        System.debug('insert multiJobId-->'+multiJobId+'WO.SVMXC__Dependency_Group__c-->'+WO.SVMXC__Dependency_Group__c);
                        woIsPartOfDependentGroup = true;
                        if(WoDetail != null){
                            WoDetail = WoDetail + ',' +WO.Name;
                        }else{
                            WoDetail = WO.Name;
                        }
                    }
                }
            }
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::validateDependencyGroup::woDoNotQualify:'+woDoNotQualify+'woIsPartOfDependentGroup:'+woIsPartOfDependentGroup);
        /*SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.Id = 'abc';
        insert wo;*/
        }catch(exception ex){
            String exceptionMsg = 'WSCH_DependencyTriggerHandler :: validateDependencyGroup';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());  
        }
        for(Service_Order_Dependency__c svcOrder: svcOdrList){
            if(isCostIdDoesNotExist){
                svcOrder.addError(system.label.DCON003_TAG093);
            }
            else if(isTargetTimeInvalid){
                svcOrder.addError(system.label.DCON003_TAG094);
            }
            else if(isLatestLessThenEarliest){
                //svcOrder.addError(system.label.DCON003_TAG095);
            }
            /*else if(hasMultipleConnectionNames){
                svcOrder.addError(system.label.DCON003_TAG096);
            }*/
            else if(woDoNotQualify){
                svcOrder.addError(system.label.DCON003_TAG097+':'+WoDetail);
            }
            else if(woIsPartOfDependentGroup){
                svcOrder.addError(system.label.DCON003_TAG098+':'+WoDetail);
            }
        }             
    }
    
    // Method to check if dependency records are qualified for a group dependency API call on update.
    public static boolean markChangeToken(Service_Order_Dependency__c newDependencyRecord, Service_Order_Dependency__c oldDependencyRecord){
        Boolean isQualifyAndMark = false;
        String schedulingChangeToken = '';
        WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken():start: isQualifyAndMark -' + isQualifyAndMark);
        if(newDependencyRecord.SVMXC__Primary_Work_Order__c != oldDependencyRecord.SVMXC__Primary_Work_Order__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): primary WO changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
            
            //if the Old WO is replaced with a new WO in the WO Dependency record, nullify the Group ID from the Old WO
            SVMXC__Service_Order__c woToUpdate = WSCH_CommonUtils.fetchWorkOrderById(String.valueOf(oldDependencyRecord.SVMXC__Primary_Work_Order__c));
            woToUpdate.SVMXC__Dependency_Group__c = null;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( woToUpdate, COMM_SecurityUtils.Access.Upsertable) ) {       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert woToUpdate;
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return null;
            }
        }
        else if(newDependencyRecord.SVMXC__Secondary_Work_Order__c != oldDependencyRecord.SVMXC__Secondary_Work_Order__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): secondary WO changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
            
            //if the Old WO is replaced with a new WO in the WO Dependency record, nullify the Group ID from the Old WO
            SVMXC__Service_Order__c woToUpdate = WSCH_CommonUtils.fetchWorkOrderById(String.valueOf(oldDependencyRecord.SVMXC__Secondary_Work_Order__c));
            woToUpdate.SVMXC__Dependency_Group__c = null;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( woToUpdate, COMM_SecurityUtils.Access.Upsertable) ) {       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert woToUpdate;
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return null;
            }
        }
        else if(newDependencyRecord.SVMXC__Resource_Dependency__c != oldDependencyRecord.SVMXC__Resource_Dependency__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): resource dependency changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
        }
        else if(newDependencyRecord.SVMXC__Time_Dependency__c != oldDependencyRecord.SVMXC__Time_Dependency__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): time dependency changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
        }
        else if(newDependencyRecord.SVMXC__Minimum_Time_Deviation__c != oldDependencyRecord.SVMXC__Minimum_Time_Deviation__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): minimum time deviation changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
        }
        else if(newDependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c != oldDependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): min time deviation units changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
        }
        else if(newDependencyRecord.SVMXC__Maximum_Time_Deviation__c != oldDependencyRecord.SVMXC__Maximum_Time_Deviation__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): max time deviation changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
        }
        else if(newDependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c != oldDependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): max time deviation units changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
        }
        else if(newDependencyRecord.SVMXC__Dependency_Group__c != oldDependencyRecord.SVMXC__Dependency_Group__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): dependency group changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
        }
        else if(newDependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c != oldDependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): cost Id changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
        }
        else if(newDependencyRecord.SVMXC__Targeted_Time_Difference__c != oldDependencyRecord.SVMXC__Targeted_Time_Difference__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): targeted time diff changed');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
        }
        else if(newDependencyRecord.SVMXC__Targeted_Time_Difference_Units__c != oldDependencyRecord.SVMXC__Targeted_Time_Difference_Units__c){
            //schedulingChangeToken = 'CHANGE_DEPENDENCY_WO';
            isQualifyAndMark = true;
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): targeted time diff units');
            WSCH_AuditLogger.debug('WSCH_DependencyTriggerHandler::markChangeToken(): isQualifyAndMark -' + isQualifyAndMark);
        }
        
        return isQualifyAndMark;
    }
}