global with sharing class WSCH_Jeopardy_Manager_Scheduler implements Schedulable {
        
    public static String  JEOPARDY_SCHEDULER_NAME = 'WSCH_Jeopardy_Manager_SchHandler';
    
    global void execute(SchedulableContext sc)
    {
        system.abortJob(sc.getTriggerID()); // Always abort the job on completion
        SVMXC.WSCH_Jeopardy_Manager_SchHandler pushBatchApex = new SVMXC.WSCH_Jeopardy_Manager_SchHandler();
        WSCH_Jeopardy_Manager_SchHandler.undoJeopardyAfterTechUpdate();
        WSCH_Jeopardy_Manager_SchHandler.getWOInJeopardy_For_Unresourced_Unscheduled(); 
        WSCH_Jeopardy_Manager_SchHandler.getWOInJeopardy_Scheduled_NotProgressing(); 
        WSCH_Jeopardy_Manager_SchHandler.getWOInCascadingJeopardy();
        createCronJob(5);
    }
    
    global void startJeopardyPushScheduler(){
        createCronJob(5);
    }    
    
    private static Boolean scheduledInContext = false;
    
    public static String getSchedulerExpression(Datetime dt) {

        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }
        
    public static boolean createCronJob(Integer schedulerStartTime)
    {
        system.debug('WSCH_Jeopardy_Manager_Scheduler::createCronJob()::batch apex class name '+JEOPARDY_SCHEDULER_NAME);

        if(scheduledInContext) {
            system.debug('WSCH_Jeopardy_Manager_SchHandler::createCronJob()::scheduledInContext- '+scheduledInContext);
            return false;
        }
        
        scheduledInContext = true;

        String cronJobName = JEOPARDY_SCHEDULER_NAME + '_scheduler';
        /*
            Following logic checks if same cron job is running , then returns false.
        */
        Boolean isCronJobRunning = SVMXC.WSCH_CommonUtils.isCronJobRunning(cronJobName);
        if(isCronJobRunning) {
            system.debug('WSCH_Jeopardy_Manager_Scheduler::createCronJob()::isCronJobRunning- '+isCronJobRunning);          
             return false;    // Already running
        }

        Set<String> activejobstates = new Set<String>{'Queued','Processing','Preparing'};

        List<AsyncApexJob> apexjobs = [Select ID, ApexClass.Name from AsyncApexJob where ApexClass.Name = :JEOPARDY_SCHEDULER_NAME And Status in :activejobstates];	//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(apexjobs.size() > 0) {
            system.debug('WSCH_Jeopardy_Manager_Scheduler::createCronJob()::apexjobs.size() - '+apexjobs.size());
            return false;  // The batch is running
        }

        String settingValue = SVMXC.WSCH_CommonUtils.getSettingValue('DCON006', 'SET001');
        if(String.isNotBlank(settingValue)){
            schedulerStartTime = Integer.valueOf(settingValue);
        }
        if (schedulerStartTime == null || schedulerStartTime == 0) {
            schedulerStartTime = 0;
        }
        
        system.debug('WSCH_Jeopardy_Manager_Scheduler::createCronJob()::cronJobName '+cronJobName);
        system.debug('WSCH_Jeopardy_Manager_Scheduler::createCronJob()::apexjobs '+apexjobs);
        WSCH_Jeopardy_Manager_Scheduler Scheduler = new WSCH_Jeopardy_Manager_Scheduler();
        System.schedule(cronJobName, getSchedulerExpression(DateTime.Now().addMinutes(schedulerStartTime)), Scheduler);
        return true;
    }
}