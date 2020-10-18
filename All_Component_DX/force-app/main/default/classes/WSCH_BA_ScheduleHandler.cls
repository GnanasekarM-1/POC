public class WSCH_BA_ScheduleHandler implements WSCH_BA_ScheduledDispatcher.WSCH_IScheduleDispatched{
    
    public void execute(SchedulableContext sc, String batchApexName)
    {
    
        system.abortJob(sc.getTriggerID()); // Always abort the job on completion
        Type targetType = Type.forName(batchApexName);   
        if (targetType != null) {
            WSCH_BatchApex_Interface obj = (WSCH_BatchApex_Interface) targetType.NewInstance();
            obj.startBatch();   
        }
    } 

    public static String getSchedulerExpression(Datetime dt) {
        
        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }

    private static Boolean scheduledInContext = false;

    public static void startBatchApex(String batchApexName, Integer schedulerStartTime)
    {
        
        Type targetType = Type.forName(batchApexName);   
        if (targetType == null) {
            return;   
        }
        
        WSCH_BatchApex_Interface obj = (WSCH_BatchApex_Interface) targetType.NewInstance();
        if(!obj.hasPendingObjects()) {
            return;
        }
        
        if(scheduledInContext) {
            return;
        }
       
        scheduledInContext = true;
        
        String cronJobName = batchApexName + '_schedule';
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime FROM CronTrigger where CronJobDetail.Name= :cronJobName];
        if(jobs.size()>0 && jobs[0].state!='COMPLETED' && jobs[0].state!='ERROR' && jobs[0].state!='DELETED') {
             return;    // Already running
        }
        
        Set<String> activejobstates = new Set<String>{'Queued','Processing','Preparing'};
        List<AsyncApexJob> apexjobs = [Select ID, ApexClass.Name from AsyncApexJob where ApexClass.Name = :batchApexName And Status in :activejobstates];
        if(apexjobs.size() > 0) {
             return;  // The batch is running
        }
        
        if (schedulerStartTime== null || schedulerStartTime== 0) {
            schedulerStartTime= 120;
        }
        
        System.schedule(cronJobName, getSchedulerExpression(DateTime.Now().addSeconds(schedulerStartTime)), new WSCH_BA_ScheduledDispatcher(batchApexName));
    }
    
}