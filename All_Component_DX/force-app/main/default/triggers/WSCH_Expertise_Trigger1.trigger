trigger WSCH_Expertise_Trigger1 on Service_Group_Skills__c (before insert, after insert,before update, before delete) {
    
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    list<string> lstSubModules = new list<string>{'GLOB001','OMAX001','OMAX003','SLAT003','PREV004','IPRD009','EVER007','IPRD003','DCON002','DCON003','DCON004','WORD023', 'WORD012','IPAD018','SORG001'};
    map<string, Map<String, String>> AllsvmxSettingList = new map<string, Map<String, String>>();
    
    //create settings cache..
    if(SVMX_Constants.AllsvmxSettingList == NULL || SVMX_Constants.AllsvmxSettingList.size() == 0) {
        SVMX_Constants.AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
    }
    
    //getting active real time optimization provider
    String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
    System.debug('Active Provider: ' + strActiveProvider);
    
    if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO') && !WSCH_OptimizedSchedulingService.triggerExecuted){
        if(Trigger.isInsert && Trigger.isAfter) 
        {
            WSCH_ExpertiseTriggerHandler.handleExpertiseInsert(Trigger.new);            
        }
        else if(Trigger.isUpdate && Trigger.isBefore) 
        {
            WSCH_ExpertiseTriggerHandler.handleExpertiseUpdate(Trigger.new,Trigger.old);            
        }
        else if(Trigger.isDelete && Trigger.isBefore) 
        {
            WSCH_ExpertiseTriggerHandler.handleExpertiseDelete(Trigger.old);            
        }    
    }
}