@isTest
private class WSCH_Provider_ECO_Scheduler_UT {

    static testMethod void WSCH_Provider_ECO_Scheduler_UT1() {
        Test.startTest();
        
        String sch = '0 0 8 13 2 ?';     
        WSCH_Provider_ECO_Scheduler handler = new WSCH_Provider_ECO_Scheduler();
        String jobId = system.schedule('One Time Pro', sch, handler);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,  NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        handler.startSyncScheduler();
         
        System.assertEquals(sch, ct.CronExpression);
         
        Test.stopTest();        
    }
}