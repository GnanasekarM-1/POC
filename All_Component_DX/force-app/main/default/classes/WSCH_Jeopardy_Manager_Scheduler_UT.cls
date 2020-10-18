@isTest
public with sharing class WSCH_Jeopardy_Manager_Scheduler_UT {
    
    public WSCH_Jeopardy_Manager_Scheduler_UT() {
      
    }
    
    static{
        WSCH_Jeopardy_Manager_Scheduler_UT retrySchedulerUT = new WSCH_Jeopardy_Manager_Scheduler_UT();
    }
    
    static testMethod void jeopardySchedulerHandlerExecuteUT() {
      
      test.startTest();
      
      WSCH_Jeopardy_Manager_Scheduler jeopardyHandler = new WSCH_Jeopardy_Manager_Scheduler();
      
      jeopardyHandler.startJeopardyPushScheduler();
      
      test.stopTest();
    }
    
}