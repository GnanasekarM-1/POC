/*
   This batch apex is used to get the WO updates or changes from SP.
*/

global class WSCH_Provider_SP_WOUpdatesBatchApex implements WSCH_BatchApex_Interface, Database.Batchable<sObject>, Database.AllowsCallouts {

    public boolean hasPendingObjects() {

        return true;
    }

    public void startBatch() {
        WSCH_Provider_SP_WOUpdatesBatchApex.startTheBatch();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator(WSCH_Constants.GET_CHANGES_BATCH_QUERY_STRING);
    }

    global void execute(Database.BatchableContext BC, List<SVMXC__Territory__c> territories){
        WSCH_OptimizedSchedulingService.triggerExecuted = true;
        WSCH_OptimizedSchedulingService.getChangedWorkOrders(territories.get(0));
    }

    global void finish(Database.BatchableContext BC){

        String settingValue = WSCH_CommonUtils.getSettingValue('DCON004', 'SET007');
        Integer settingTimeDelay = 30; //Default Value.
        if(String.isNotBlank(settingValue)){
            settingTimeDelay = Integer.valueOf(settingValue);
        }
        WSCH_Provider_SP_WOUpdatesSchHandler.WO_UPDATES_BATCHAPEX_NAME='WSCH_Provider_SP_WOUpdatesBatchApex';
        WSCH_Provider_SP_WOUpdatesSchHandler.startBatchApex(settingTimeDelay);
        WSCH_AuditLogger.finish();
    }

    public static void startTheBatch()
    {
        WSCH_Provider_SP_WOUpdatesBatchApex workOrderUpdatesBatchApex = new WSCH_Provider_SP_WOUpdatesBatchApex();
        if (WSCH_BA_CommonUtils.canExecuteBatchApex()) {
            Database.executeBatch(workOrderUpdatesBatchApex, WSCH_Constants.GET_CHANGES_BATCH_SIZE);
        } else {
            //TODO : Need confirm the time delay here.
            WSCH_Provider_SP_WOUpdatesSchHandler.startBatchApex(30);
        }
    }

}