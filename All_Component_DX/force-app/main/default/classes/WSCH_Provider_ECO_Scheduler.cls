global class WSCH_Provider_ECO_Scheduler implements Schedulable {
    
    public Interface WSCH_ECO_IScheduleDispatched 
    { 
        void execute(SchedulableContext sc); 
    } 
    
    global void execute(SchedulableContext sc) 
    {
        Type targetType = Type.forName('WSCH_Provider_ECO_SchedulerHandler');   
        if (targetType != null) {
            WSCH_ECO_IScheduleDispatched obj = (WSCH_ECO_IScheduleDispatched) targetType.NewInstance();
            obj.execute(sc);  
        } 
    }
    
    global void startSyncScheduler()
    {
        WSCH_Provider_ECO_SchedulerHandler.startRetryCronJob(30);
    }
}