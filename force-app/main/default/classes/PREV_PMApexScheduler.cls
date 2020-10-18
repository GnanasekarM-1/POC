global with sharing class PREV_PMApexScheduler implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        Integer intBatchSize = 1;
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('PREV003');
        if(svmxSettingList.containskey('SET001'))
            intBatchSize = integer.valueof(svmxSettingList.get('SET001'));
        PREV_PMScheduler pm = new PREV_PMScheduler();
        ID batchprocessid = Database.executeBatch(pm,intBatchSize); 
    }
}