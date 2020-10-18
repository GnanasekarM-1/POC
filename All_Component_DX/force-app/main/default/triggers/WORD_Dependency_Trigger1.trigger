/*
 *  Author : 
 *  Ver & Date :
 *  Description :
 */

trigger WORD_Dependency_Trigger1 on Service_Order_Dependency__c (before insert, before update, after insert, after update, before delete) {
    
    WSCH_AuditLogger.debug('WORD_Dependency_Trigger1: Inside workorder dependency trigger');
    Map<String, List<Service_Order_Dependency__c>> newServiceOrderMap = new Map<String, List<Service_Order_Dependency__c>>();
    Map<String, List<Service_Order_Dependency__c>> oldserviceOrderMap = new Map<String, List<Service_Order_Dependency__c>>();
    List<SVMXC__Service_Order__c> woList = new List<SVMXC__Service_Order__c>();
    newServiceOrderMap = WSCH_DependencyTriggerHandler.getDependencyMap(Trigger.new);
    
    WSCH_AuditLogger.debug('WORD_Dependency_Trigger1: Inside workorder dependency trigger:Trigger.new - ' + Trigger.new);
    WSCH_AuditLogger.debug('WORD_Dependency_Trigger1: Inside workorder dependency trigger:Trigger.old - ' + Trigger.old);
    
    if(!Trigger.isDelete && newServiceOrderMap == null) {
        WSCH_AuditLogger.finish();
        return;
    }
    
    if(Trigger.isDelete && Trigger.isBefore) {
        List<Service_Order_Dependency__c> lstOfDeletedWODependencyRecord = Trigger.old;
        List<Service_Order_Dependency__c> lstOfCurrentWODependencyRecord = Trigger.new;
        WSCH_AuditLogger.debug('deletedWODependencyRecord -' + lstOfDeletedWODependencyRecord);
        WSCH_AuditLogger.debug('lstOfCurrentWODependencyRecord -' + lstOfCurrentWODependencyRecord);
        
        WSCH_DependencyTriggerHandler.deleteWODependencyFromGroup(Trigger.old);
        return;
    }
    
    List<SVMXC__Service_Order_Dependency__c>  service_Order_Group_Dependency = Trigger.new;
    
    Set<String> WO_Ids = new Set<String>();
    for(SVMXC__Service_Order_Dependency__c groupDependencyRecords: service_Order_Group_Dependency){
        WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Primary_Work_Order__c));
        WO_Ids.add(string.valueof(groupDependencyRecords.SVMXC__Secondary_Work_Order__c));
    }
    List<String> WoIdList = new List<String>();
    WoIdList.addAll(WO_Ids);
    woList = WSCH_CommonUtils.fetchWorkOrders(WoIdList);
    WSCH_AuditLogger.debug('woList-->'+woList);
    
    //Map<Id,SVMXC__ServiceMax_Processes__c> svmxBatchProcessMap = WSCH_CommonUtils.getOptimizedBatchDP();
    //Map<Id,SVMXC__ServiceMax_Processes__c> svmxEcoProcessMap = WSCH_CommonUtils.getEcoDP();
    List<SVMXC__Service_Order__c> dependencyGroupWoList = new List<SVMXC__Service_Order__c>();
    
    //get the map of old dependency records for before update validation
    if(Trigger.isUpdate){
        oldserviceOrderMap = WSCH_DependencyTriggerHandler.getDependencyMap(Trigger.old);
    }
    WSCH_AuditLogger.debug('WORD_Dependency_Trigger1::newServiceOrderMap:'+newServiceOrderMap);
    //process dependency records of one group at a time based on group id
    for(String dependencyGroupId : newServiceOrderMap.keySet()){
        List<Service_Order_Dependency__c > svcOrdrList = new List<Service_Order_Dependency__c >();
        svcOrdrList = newServiceOrderMap.get(dependencyGroupId);
        if(Trigger.isBefore){
            system.debug('inside isBefore');
            if(Trigger.isInsert && oldserviceOrderMap == null){
                WSCH_DependencyTriggerHandler.validateDependencyGroup(svcOrdrList, dependencyGroupId,'beforeInsert');
            }
            if(Trigger.isUpdate){
                
                //ECO code for Dependency WOs 
                if(woList != null && !woList.isEmpty()) {
                    WSCH_DependencyTriggerHandler.validateDependencyGroup(svcOrdrList, dependencyGroupId,'beforeUpdate');
                    WSCH_DependencyTriggerHandler.doQualifyUpdatedDependency(newServiceOrderMap.get(dependencyGroupId), oldServiceOrderMap.get(dependencyGroupId));
                }
            }
        }        
        if(Trigger.isInsert && Trigger.isAfter){           
            WSCH_AuditLogger.debug('inside after insert');
            
            //ECO code for Dependency WOs
            if(woList != null && !woList.isEmpty()) {
                WSCH_DependencyTriggerHandler.doQualifyInsertDependency(Trigger.new, woList);
            }
        }     
    }
    
    WSCH_AuditLogger.finish();
}