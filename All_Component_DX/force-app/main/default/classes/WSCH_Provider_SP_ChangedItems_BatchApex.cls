/*
   This batch apex is used to get the Push Notifications from SP.
*/

global class WSCH_Provider_SP_ChangedItems_BatchApex implements WSCH_BatchApex_Interface, Database.Batchable<sObject>, Database.AllowsCallouts {

    public boolean hasPendingObjects() {

        return true;
    }

    public void startBatch() {
        WSCH_Provider_SP_ChangedItems_BatchApex.startTheBatch();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator(WSCH_Constants.GET_PUSH_JSON_STRING);
    }

    global void execute(Database.BatchableContext BC, List<SVMXC__SVMX_Optimizer__c> optimizers){
        WSCH_Provider_SP_ChangedItems_Helper.doProcessRequest(optimizers);
    }
    
    global void finish(Database.BatchableContext BC){

        /*String settingValue = WSCH_CommonUtils.getSettingValue('DCON004', 'SET007');
        Integer settingTimeDelay = 30; //Default Value.
        if(String.isNotBlank(settingValue)){
            settingTimeDelay = Integer.valueOf(settingValue);
        }
        WSCH_Provider_SP_WOUpdatesSchHandler.WO_UPDATES_BATCHAPEX_NAME='WSCH_Provider_SP_ChangedItems_BatchApex';
        WSCH_Provider_SP_WOUpdatesSchHandler.startBatchApex(settingTimeDelay);*/
        WSCH_AuditLogger.finish();
    }

    public static void startTheBatch()
    {
        WSCH_Provider_SP_ChangedItems_BatchApex changeItemsBatchApex = new WSCH_Provider_SP_ChangedItems_BatchApex();
        if (WSCH_BA_CommonUtils.canExecuteBatchApex()) {
            Database.executeBatch(changeItemsBatchApex, WSCH_Constants.GET_PUSH_BATCH_SIZE);
        } else {
            //TODO : Need confirm the time delay here.
            WSCH_Provider_SP_WOUpdatesSchHandler.startBatchApex(30);
        }
    }

}