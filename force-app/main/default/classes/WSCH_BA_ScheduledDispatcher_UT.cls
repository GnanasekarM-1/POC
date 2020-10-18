@isTest
private class WSCH_BA_ScheduledDispatcher_UT {
    static testmethod void testWSCH_BA_ScheduledDispatcher() {
        String CRON_EXP = '0 0 0 3 9 ? 2025';
        Test.startTest();
            String jobId = System.schedule('WSCH_BA_ScheduledDispatcher',CRON_EXP,new WSCH_BA_ScheduledDispatcher(WSCH_Constants.WO_BATCH_CLASS_NAME));
            //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();
    }

}