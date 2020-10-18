@isTest
public with sharing class WSCH_Provider_SP_Scheduler_UT {
     static testMethod void WSCH_Provider_SP_Scheduler_UT_test(){
     
     Test.startTest();
     
     String sch = '0 0 8 13 2 ?';     
     WSCH_Provider_SP_Scheduler handler = new WSCH_Provider_SP_Scheduler();
     String jobId = system.schedule('One Time Pro', sch, handler);
     CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,  NextFireTime FROM CronTrigger WHERE id = :jobId];
     
     handler.startSyncScheduler();
     
     System.assertEquals(sch, ct.CronExpression);
     
     Test.stopTest();
     
     }
}