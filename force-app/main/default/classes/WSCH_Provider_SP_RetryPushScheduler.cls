global with sharing class WSCH_Provider_SP_RetryPushScheduler implements Schedulable {
        
    public static String  PUSH_BATCHAPEX_NAME = 'WSCH_Provider_SP_ChangedItems_BatchApex';
    
    global void execute(SchedulableContext sc)
    {
        system.abortJob(sc.getTriggerID()); // Always abort the job on completion
        SVMXC.WSCH_Provider_SP_ChangedItems_BatchApex pushBatchApex = new SVMXC.WSCH_Provider_SP_ChangedItems_BatchApex();
        Database.executeBatch(pushBatchApex, 10);
        createCronJob(30);
    }
    
    global void startRetryPushScheduler(){
        createCronJob(30);
    }    
    
    private static Boolean scheduledInContext = false;
    
    public static String getSchedulerExpression(Datetime dt) {

        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }
        
    public static boolean createCronJob(Integer schedulerStartTime)
    {
        system.debug('WSCH_Provider_SP_RetryPushScheduler::createCronJob()::batch apex class name '+PUSH_BATCHAPEX_NAME);

        if(scheduledInContext) {
            system.debug('WSCH_Provider_SP_RetryPushScheduler::createCronJob()::scheduledInContext- '+scheduledInContext);
            return false;
        }
        
        scheduledInContext = true;

        String cronJobName = PUSH_BATCHAPEX_NAME + '_scheduler';
        /*
            Following logic checks if same cron job is running , then returns false.
        */
        Boolean isCronJobRunning = SVMXC.WSCH_CommonUtils.isCronJobRunning(cronJobName);
        if(isCronJobRunning) {
            system.debug('WSCH_Provider_SP_RetryPushScheduler::createCronJob()::isCronJobRunning- '+isCronJobRunning);          
             return false;    // Already running
        }

        Set<String> activejobstates = new Set<String>{'Queued','Processing','Preparing'};

        List<AsyncApexJob> apexjobs = [Select ID, ApexClass.Name from AsyncApexJob where ApexClass.Name = :PUSH_BATCHAPEX_NAME And Status in :activejobstates];
        if(apexjobs.size() > 0) {
            system.debug('WSCH_Provider_SP_RetryPushScheduler::createCronJob()::apexjobs.size() - '+apexjobs.size());
            return false;  // The batch is running
        }

        String settingValue = SVMXC.WSCH_CommonUtils.getSettingValue('DCON004', 'SET007');
        if(String.isNotBlank(settingValue)){
            schedulerStartTime = Integer.valueOf(settingValue);
        }
        if (schedulerStartTime == null || schedulerStartTime == 0) {
            schedulerStartTime = 30;
        }
        
        system.debug('WSCH_Provider_SP_RetryPushScheduler::createCronJob()::cronJobName '+cronJobName);
        system.debug('WSCH_Provider_SP_RetryPushScheduler::createCronJob()::apexjobs '+apexjobs);
        WSCH_Provider_SP_RetryPushScheduler pushScheduler = new WSCH_Provider_SP_RetryPushScheduler();
        System.schedule(cronJobName, getSchedulerExpression(DateTime.Now().addSeconds(schedulerStartTime)), pushScheduler);
        return true;
    }
}