trigger WORD_DependencyGroup_Trigger1 on Dependency_Management__c (before delete) {

    WSCH_AuditLogger.debug('Inside WORD_DependencyGroup_Trigger1: start');
    WSCH_AuditLogger.debug('Inside WORD_DependencyGroup_Trigger1: dependencyGroupObject size:' + trigger.old.size());
    
    List<id> depGroupIds = new List<id>();
    for(Dependency_Management__c eachDepGroupObj : trigger.old)
    {
        depGroupIds.add(eachDepGroupObj.id);
    }
    
    //Collecting all child records related to Parent records
    list<SVMXC__Service_Order_Dependency__c> listOfDepObjectsToDel = [select Id, SVMXC__Primary_Work_Order__c, SVMXC__Secondary_Work_Order__c from SVMXC__Service_Order_Dependency__c where SVMXC__Dependency_Group__c in :depGroupIds];
    WSCH_AuditLogger.debug('List of dependency objects to delete listOfDepObjectsToDel.size() - '+listOfDepObjectsToDel.size());
    //deleting child records
    //delete listOfDepObjectsToDel;
    WSCH_DependencyTriggerHandler.deleteWODependencyFromGroup(listOfDepObjectsToDel);
}