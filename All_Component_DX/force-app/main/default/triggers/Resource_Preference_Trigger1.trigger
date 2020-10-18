trigger Resource_Preference_Trigger1 on Resource_Preference__c (before insert, before update){
    List<Resource_Preference__c> lstAllResPref = new List<Resource_Preference__c>();
    List<Resource_Preference__c> lstResPref = new List<Resource_Preference__c>();
    Set<Id> techId = new Set<Id>();
    try{
        for (Resource_Preference__c tech : System.Trigger.new) {
            // Make sure we don't treat a record that doesn't have a Technician.
            if ((tech.SVMXC__Group_Member__c != null)) {
                lstResPref.add(tech);
                techId.add(tech.SVMXC__Group_Member__c);
            }
        }
        //lstResPref - current list of roecords in the trigger.
        //all resorce pref records with techId in the system.       
        lstAllResPref =  ResourcePreferenceTriggerHandler.getAllRes(techId);
        if(Trigger.isInsert){
            WSCH_AuditLogger.debug('INSIDE Resource_Preference_Trigger1: BEFORE INSERT');
            ResourcePreferenceTriggerHandler.checkResPrefList(lstAllResPref,lstResPref,'beforeInsert');
        }
        if(Trigger.isUpdate){
            WSCH_AuditLogger.debug('INSIDE Resource_Preference_Trigger1: BEFORE UPDATE');
            //Map<Id,Resource_Preference__c> mapTrigOld = new Map<Id,Resource_Preference__c>(Trigger.oldMap);
            ResourcePreferenceTriggerHandler.checkResPrefList(lstAllResPref,lstResPref,'beforeUpdate');
            //ResourcePreferenceTriggerHandler.checkUpdateResList(lstAllResPref,lstResPref, Trigger.oldMap, Trigger.newMap);
        }
    }catch(exception ex){
        String exceptionMsg = 'Resource_Preference_Trigger1 :: ';
        WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
    }
}